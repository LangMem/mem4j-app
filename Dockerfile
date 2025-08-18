# Copyright 2024-2026 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Multi-stage build for better layer caching and smaller final image

# Stage 1: Build stage
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

# Set working directory
WORKDIR /app

# Copy Maven configuration files first for better layer caching
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-alpine AS runtime

# Install necessary packages for better security and functionality
RUN apk add --no-cache \
    curl \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S mem4j && \
    adduser -u 1001 -S mem4j -G mem4j

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/logs /app/config /app/tmp && \
    chown -R mem4j:mem4j /app

# Copy the built JAR from builder stage
COPY --from=builder /app/target/mem4j-app-*.jar /app/mem4j-app.jar

# Change ownership of the JAR file
RUN chown mem4j:mem4j /app/mem4j-app.jar

# Switch to non-root user
USER mem4j

# Expose port
EXPOSE 8080

# Health check (using memory search endpoint since no actuator)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f "http://localhost:8080/api/v1/memory/search?query=health&userId=health&limit=1" || exit 1

# Set JVM options for better performance and monitoring
ENV JAVA_OPTS="-Xmx512m -Xms256m \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+ExitOnOutOfMemoryError \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+UseCGroupMemoryLimitForHeap \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.backgroundpreinitializer.ignore=true \
    -Dfile.encoding=UTF-8 \
    -Duser.timezone=Asia/Shanghai"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/mem4j-app.jar"] 
