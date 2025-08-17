# Mem4j Application

This is the main Spring Boot application for Mem4j - a long-term memory system for AI agents. The application provides REST APIs for memory operations including adding, searching, updating, and deleting memories.

## Features

- **Memory Management**: Add, search, update, and delete memories
- **Vector Search**: Semantic search using embeddings
- **Multiple Storage Types**: Support for in-memory and external vector stores
- **LLM Integration**: Support for DashScope and OpenAI
- **RESTful API**: Complete REST API for memory operations
- **H2 Database**: Embedded database for metadata storage

## Quick Start

### Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- DashScope API Key (optional, for LLM features)

### Running the Application

1. **Clone and navigate to the project**:

   ```bash
   git clone <repository-url>
   cd mem4j/mem4j-app
   ```

2. **Set environment variables** (optional):

   ```bash
   export DASHSCOPE_API_KEY=your-api-key-here
   ```

3. **Run the application**:

   ```bash
   mvn spring-boot:run
   ```

4. **Verify the application is running**:
   The application will start on `http://localhost:8080/api/v1`

## Configuration

The application uses `application.yml` for configuration. Key configuration sections:

### Database Configuration

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:mem4jdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
```

### Mem4j Configuration

```yaml
mem4j:
  vector-store:
    type: inmemory # Vector store type: inmemory, qdrant, elasticsearch
    collection: memories # Collection name
    options:
      similarity-threshold: 0.7 # Similarity threshold for search

  llm:
    type: dashscope # LLM provider: dashscope, openai
    api-key: ${DASHSCOPE_API_KEY} # API key from environment variable
    model: qwen-turbo # Model name
    options:
      max-tokens: 1000
      temperature: 0.7

  embeddings:
    type: dashscope # Embedding provider: dashscope, openai
    model: text-embedding-v1 # Embedding model
    options:
      dimensions: 1536 # Embedding dimensions
```

## API Endpoints

The application provides the following REST endpoints:

### Add Memories

```http
POST /api/v1/memory/add
Content-Type: application/json

{
  "messages": [
    {
      "role": "user",
      "content": "I love pizza"
    },
    {
      "role": "assistant",
      "content": "That's great! Pizza is delicious."
    }
  ],
  "userId": "user123",
  "metadata": {
    "topic": "food_preferences"
  },
  "infer": true,
  "memoryType": "factual"
}
```

### Search Memories

```http
GET /api/v1/memory/search?query=pizza&userId=user123&limit=10&threshold=0.7
```

### Get All Memories

```http
GET /api/v1/memory/all?userId=user123&limit=100
```

### Get Specific Memory

```http
GET /api/v1/memory/{memoryId}
```

### Update Memory

```http
PUT /api/v1/memory/{memoryId}
Content-Type: application/json

{
  "content": "Updated content",
  "metadata": {
    "updated": true
  }
}
```

### Delete Memory

```http
DELETE /api/v1/memory/{memoryId}
```

### Delete All Memories for User

```http
DELETE /api/v1/memory/user/{userId}
```

### Reset All Memories

```http
POST /api/v1/memory/reset
```

## API Response Format

All API responses follow this format:

**Success Response:**

```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "results": [...],
  "count": 10
}
```

**Error Response:**

```json
{
  "status": "error",
  "message": "Error description"
}
```

## Memory Types

The system supports different types of memories:

- **factual**: Stores facts and information
- **episodic**: Stores events and experiences
- **semantic**: Stores concepts and relationships
- **procedural**: Stores how-to information
- **working**: Temporary information for current task

## Testing the API

You can test the API using curl, Postman, or any HTTP client:

### Example: Add a memory

```bash
curl -X POST http://localhost:8080/api/v1/memory/add \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "I work as a software engineer"},
      {"role": "assistant", "content": "That sounds like an interesting career!"}
    ],
    "userId": "user123",
    "metadata": {"topic": "career"},
    "infer": true,
    "memoryType": "factual"
  }'
```

### Example: Search memories

```bash
curl "http://localhost:8080/api/v1/memory/search?query=software%20engineer&userId=user123&limit=5"
```

## Configuration Options

### Vector Store Types

- `inmemory`: Simple in-memory vector store (default)
- `qdrant`: Qdrant vector database
- `elasticsearch`: Elasticsearch vector search

### LLM Providers

- `dashscope`: Alibaba Cloud DashScope
- `openai`: OpenAI GPT models

### Embedding Providers

- `dashscope`: Alibaba Cloud DashScope embeddings
- `openai`: OpenAI embeddings

## Environment Variables

| Variable                 | Description                              | Default                  |
| ------------------------ | ---------------------------------------- | ------------------------ |
| `DASHSCOPE_API_KEY`      | DashScope API key for LLM and embeddings | `your-dashscope-api-key` |
| `SPRING_PROFILES_ACTIVE` | Spring profile to activate               | `default`                |

## Building and Packaging

### Build the application

```bash
mvn clean compile
```

### Run tests

```bash
mvn test
```

### Package as JAR

```bash
mvn clean package
```

### Run the packaged JAR

```bash
java -jar target/mem4j-app-0.1.0.jar
```

## Development

### Project Structure

```
mem4j-app/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/github/mem4j/app/
│       │       ├── Mem4jApplication.java      # Main application class
│       │       └── controllers/
│       │           └── MemoryController.java   # REST API controller
│       └── resources/
│           └── application.yml                 # Configuration file
├── pom.xml                                    # Maven dependencies
└── README.md                                  # This file
```

### Adding Custom Configuration

You can override default configuration by:

1. **Environment variables**: `DASHSCOPE_API_KEY`
2. **System properties**: `-Dmem4j.vector-store.type=qdrant`
3. **Profile-specific configs**: `application-dev.yml`

## Troubleshooting

### Common Issues

**1. DataSource Configuration Error**

```
Failed to configure a DataSource: 'url' attribute is not specified
```

**Solution**: This should be resolved in the current version. The H2 database dependency is properly configured.

**2. Memory Configuration Binding Error**

```
Failed to bind properties under 'mem4j'
```

**Solution**: Ensure your configuration uses the correct `mem4j:` prefix (not `github.mem4j:`).

**3. DashScope API Key Error**

```
API key not configured
```

**Solution**: Set the `DASHSCOPE_API_KEY` environment variable or update the configuration.

### Logging

Enable debug logging for troubleshooting:

```yaml
logging:
  level:
    com.github.mem4j: DEBUG
    org.springframework: INFO
```

### Health Check

Check if the application is healthy:

```bash
curl http://localhost:8080/api/v1/actuator/health
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Support

For questions and support:

- Create an issue in the GitHub repository
- Check the documentation in the `docs/` directory
- Review the API documentation at `docs/API.md`
