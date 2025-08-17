# Docker Configuration for Mem4j

This document describes the Docker setup for the Mem4j application.

## Quick Start

### Basic Setup

```bash
# Copy environment variables
cp env.example .env
# Edit .env with your actual values

# Start core services (recommended for development)
docker-compose up -d

# Or start with all optional services
docker-compose --profile full up -d
```

### Environment-Specific Deployment

#### Development

```bash
# Start with development overrides
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Includes debugging port (5005) and Adminer for database management
```

#### Production

```bash
# Start with production optimizations
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Includes optimized JVM settings and resource limits
```

## Service Profiles

The Docker Compose setup supports different profiles for optional services:

- **Default**: Core services (mem4j, postgres, qdrant, neo4j)
- **elasticsearch**: Adds Elasticsearch
- **weaviate**: Adds Weaviate vector database
- **full**: All services including optional ones
- **monitoring**: Prometheus + Grafana (production only)

### Examples

```bash
# Start with Elasticsearch
docker-compose --profile elasticsearch up -d

# Start with Weaviate
docker-compose --profile weaviate up -d

# Start everything
docker-compose --profile full up -d

# Production with monitoring
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile monitoring up -d
```

## Services Overview

### Core Services

| Service  | Port       | Description      |
| -------- | ---------- | ---------------- |
| mem4j    | 8080       | Main application |
| postgres | 5432       | Primary database |
| qdrant   | 6333, 6334 | Vector database  |
| neo4j    | 7474, 7687 | Graph database   |

### Optional Services

| Service       | Port | Profile       | Description           |
| ------------- | ---- | ------------- | --------------------- |
| elasticsearch | 9200 | elasticsearch | Search engine         |
| weaviate      | 8081 | weaviate      | Alternative vector DB |
| adminer       | 8082 | dev only      | Database admin tool   |
| prometheus    | 9090 | monitoring    | Metrics collection    |
| grafana       | 3000 | monitoring    | Metrics visualization |

## Configuration

### Environment Variables

Create a `.env` file from `env.example`:

```bash
cp env.example .env
```

Key variables:

- `DASHSCOPE_API_KEY`: Required for LLM functionality
- `OPENAI_API_KEY`: Optional, for OpenAI services
- `POSTGRES_PASSWORD`: Database password
- `NEO4J_PASSWORD`: Neo4j password
- `JAVA_OPTS`: JVM options for the application

### Local Overrides

Create `docker-compose.override.yml` for local customization:

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

## Health Checks

All services include health checks:

- **mem4j**: `/api/v1/actuator/health`
- **postgres**: `pg_isready`
- **neo4j**: `cypher-shell`
- **qdrant**: `/health`
- **elasticsearch**: `/_cluster/health`
- **weaviate**: `/v1/.well-known/ready`

## Resource Limits

Services are configured with resource limits appropriate for their role:

### Development

- mem4j: 1.5G memory, 1 CPU
- postgres: 512M memory, 0.5 CPU
- neo4j: 1.5G memory, 1 CPU
- qdrant: 1G memory, 0.5 CPU

### Production

- mem4j: 2.5G memory, 2 CPU
- postgres: 1G memory, 1 CPU
- neo4j: 2.5G memory, 1.5 CPU
- qdrant: 2G memory, 1 CPU

## Troubleshooting

### Common Issues

1. **Service fails to start**: Check logs with `docker-compose logs <service>`
2. **Memory issues**: Increase Docker memory allocation
3. **Port conflicts**: Modify port mappings in override file
4. **Permission issues**: Ensure proper file ownership

### Useful Commands

```bash
# View logs
docker-compose logs -f mem4j

# Restart specific service
docker-compose restart mem4j

# Check service health
docker-compose ps

# Clean up
docker-compose down -v  # Warning: removes data volumes
```

## Security Notes

- All services run as non-root users where possible
- Resource limits are enforced
- No sensitive data in images
- Health checks ensure service availability
- Optional services use profiles to reduce attack surface

## Monitoring

In production, enable monitoring stack:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile monitoring up -d
```

Access:

- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090

## Backup

Important volumes to backup:

- `postgres_data`: Application data
- `neo4j_data`: Graph database
- `qdrant_data`: Vector embeddings
