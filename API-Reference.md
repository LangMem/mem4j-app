# Mem4j API Reference

基于当前代码实现的完整 API 文档。

## Base URL

所有 API 端点都基于以下 URL：

```
http://localhost:8080/api/v1/memory
```

## API 端点

### 1. 添加记忆

**POST** `/memory/add`

从对话中添加记忆。

#### 请求体示例：

```json
{
  "messages": [
    {
      "role": "user",
      "content": "我喜欢吃苹果"
    },
    {
      "role": "assistant",
      "content": "好的，我记住了你喜欢吃苹果"
    }
  ],
  "userId": "user123",
  "metadata": {
    "source": "chat",
    "timestamp": "2024-01-01T10:00:00Z"
  },
  "infer": true,
  "memoryType": "factual"
}
```

#### 参数说明：

- `messages`: 对话消息列表（必需）
- `userId`: 用户 ID（必需）
- `metadata`: 附加元数据（可选）
- `infer`: 是否推理提取记忆（默认 true）
- `memoryType`: 记忆类型，可选值：`factual`, `episodic`, `semantic`, `procedural`, `working`

#### 响应示例：

```json
{
  "status": "success",
  "message": "Memories added successfully"
}
```

### 2. 搜索记忆

**GET** `/memory/search`

搜索相关记忆。

#### 查询参数：

- `query`: 搜索查询（必需）
- `userId`: 用户 ID（必需）
- `limit`: 返回结果数量限制（默认 10）
- `threshold`: 相似度阈值（可选）
- 其他过滤参数可以作为查询参数传递

#### 示例：

```
GET /memory/search?query=苹果&userId=user123&limit=5
```

#### 响应示例：

```json
{
  "status": "success",
  "results": [
    {
      "id": "memory_id_1",
      "content": "用户喜欢吃苹果",
      "type": "factual",
      "score": 0.85,
      "metadata": {...}
    }
  ],
  "count": 1
}
```

### 3. 获取所有记忆

**GET** `/memory/all`

获取用户的所有记忆。

#### 查询参数：

- `userId`: 用户 ID（必需）
- `limit`: 返回结果数量限制（默认 100）
- 其他过滤参数

#### 示例：

```
GET /memory/all?userId=user123&limit=50
```

#### 响应格式同搜索记忆

### 4. 获取特定记忆

**GET** `/memory/{memoryId}`

根据记忆 ID 获取特定记忆。

#### 路径参数：

- `memoryId`: 记忆 ID

#### 响应示例：

```json
{
  "status": "success",
  "memory": {
    "id": "memory_id_1",
    "content": "用户喜欢吃苹果",
    "type": "factual",
    "metadata": {...}
  }
}
```

### 5. 更新记忆

**PUT** `/memory/{memoryId}`

更新指定记忆。

#### 路径参数：

- `memoryId`: 记忆 ID

#### 请求体示例：

```json
{
  "content": "更新后的记忆内容",
  "metadata": {
    "updated": "2024-01-01T11:00:00Z"
  }
}
```

#### 响应示例：

```json
{
  "status": "success",
  "message": "Memory updated successfully"
}
```

### 6. 删除记忆

**DELETE** `/memory/{memoryId}`

删除指定记忆。

#### 路径参数：

- `memoryId`: 记忆 ID

#### 响应示例：

```json
{
  "status": "success",
  "message": "Memory deleted successfully"
}
```

### 7. 删除用户所有记忆

**DELETE** `/memory/user/{userId}`

删除指定用户的所有记忆。

#### 路径参数：

- `userId`: 用户 ID

#### 响应示例：

```json
{
  "status": "success",
  "message": "All memories deleted successfully"
}
```

### 8. 重置所有记忆

**POST** `/memory/reset`

重置所有记忆（主要用于测试）。

#### 响应示例：

```json
{
  "status": "success",
  "message": "All memories reset successfully"
}
```

## 记忆类型

支持的记忆类型：

- **factual**: 事实性记忆 - 存储事实和信息
- **episodic**: 情景记忆 - 存储事件和经历
- **semantic**: 语义记忆 - 存储概念和关系
- **procedural**: 程序性记忆 - 存储操作方法信息
- **working**: 工作记忆 - 当前任务的临时信息

## 错误处理

所有 API 在发生错误时都会返回以下格式：

```json
{
  "status": "error",
  "message": "错误描述信息"
}
```

常见的 HTTP 状态码：

- `200`: 成功
- `400`: 请求参数错误
- `404`: 资源未找到
- `500`: 服务器内部错误

## cURL 示例

### 添加记忆

```bash
curl -X POST http://localhost:8080/api/v1/memory/add \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "我喜欢吃苹果"}],
    "userId": "user123",
    "memoryType": "factual"
  }'
```

### 搜索记忆

```bash
curl "http://localhost:8080/api/v1/memory/search?query=苹果&userId=user123&limit=5"
```

### 获取所有记忆

```bash
curl "http://localhost:8080/api/v1/memory/all?userId=user123"
```

## 注意事项

1. 应用当前使用的上下文路径是 `/api/v1`，所以完整的端点路径是 `/api/v1/memory/*`
2. 应用依赖 Mem4j 核心库，需要正确配置 DashScope 或 OpenAI API Key
3. 默认使用 H2 内存数据库，生产环境建议使用 PostgreSQL
4. 向量存储默认为内存模式，生产环境建议使用 Qdrant 或其他向量数据库
