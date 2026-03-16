---
name: jira-issue-reader
description: 读取和分析 Jira 工作项（Issue），获取 MOS-XXXX 工单的完整信息。通过 Jira REST API v3 获取工作项详情、历史、评论等。当用户提到 Jira 票号（如 MOS-2590）、需要查询工作项信息、读取需求、设计文档中引用票号、代码审查验证关联信息时使用。
license: Proprietary
metadata:
  author: Mosavi Team
  version: "1.0"
  project: MOS-2590
compatibility: 需要访问互联网和 Jira 实例；需要 curl 或 HTTP 客户端库；需要 Jira API Token 认证
---

# Jira 工作项读取器

## 概述

通过 Jira REST API v3 标准化地读取和分析工作项（Issue）信息。支持获取票号、描述、状态、优先级、关联信息等。

**适用场景：**
- 工作流 Step 1：读取并验证 Jira 票号内容
- 设计文档创建：引用原始需求和受理条件
- Code Review：查询关联的 Jira 信息和变更历史
- 自动化集成：CI/CD 中的票号验证

---

## 快速开始

### 基本信息

| 参数 | 值 |
|------|-----|
| **API 版本** | v3（当前最新） |
| **基础 URL** | `https://mosavi.atlassian.net/rest/api/3` |
| **认证方式** | Basic Auth（邮箱:API Token） |
| **响应格式** | JSON |

### 常用端点

```
获取单个工作项:
GET /rest/api/3/issue/{issueKey}

搜索工作项:
POST /rest/api/3/search

获取工作项历史:
GET /rest/api/3/issue/{issueKey}/changelog

创建工作项:
POST /rest/api/3/issue
```

---

## 认证：Basic Auth

**原理：** 邮箱 + API Token 的 Base64 编码

**获取 API Token：**
1. 访问 https://id.atlassian.com/manage-profile/security/api-tokens
2. 点击"创建 API Token"
3. 复制 Token（只显示一次，务必保存）

**curl 命令格式：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/ISSUE_KEY" \
  --header "Accept: application/json"
```

**具体示例：**
```bash
curl -u "user@example.com:ATATT3xFfGF09kdYSLJ9ZsIlYg0..." \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/MOS-2590" \
  --header "Accept: application/json"
```

---

## 读取工作项详情

### 请求格式

```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/MOS-XXXX?expand=changelog,transitions" \
  --header "Accept: application/json"
```

### 响应示例

```json
{
  "key": "MOS-2590",
  "id": "10000",
  "fields": {
    "summary": "Firebase Functions 到 Go 微服务迁移",
    "description": "完整的架构重构方案...",
    "status": {
      "name": "进行中",
      "id": "3"
    },
    "priority": {
      "name": "最高",
      "id": "1"
    },
    "assignee": {
      "name": "张三",
      "emailAddress": "zhangsan@mosavi.com"
    },
    "created": "2026-03-01T10:00:00.000+0800",
    "updated": "2026-03-16T15:00:00.000+0800",
    "components": [
      {
        "name": "后端架构"
      }
    ]
  }
}
```

---

## 工作流

### Step 1: 获取工作项基本信息

```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/MOS-2590" \
  --header "Accept: application/json" | jq '.fields | {summary, description, status: .status.name, priority: .priority.name, assignee: .assignee.name}'
```

**关键字段提取：**
- `summary` — 工作项标题
- `description` — 详细描述
- `status` — 状态（待处理、进行中、已完成等）
- `priority` — 优先级（最高、高、中、低）
- `assignee` — 负责人
- `created` / `updated` — 创建/更新时间
- `components` — 关联组件

### Step 2: 获取变更历史

```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/MOS-2590/changelog" \
  --header "Accept: application/json" | jq '.values[] | {created: .created, author: .author.displayName, items: .items}'
```

**使用场景：**
- 追踪状态变化
- 了解工作项的演进过程
- 验证关键决策点

### Step 3: 获取评论信息

```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/rest/api/3/issue/MOS-2590?expand=changelog" \
  --header "Accept: application/json" | jq '.fields.comment.comments[] | {author: .author.displayName, created: .created, body: .body}'
```

---

## 常见错误处理

| HTTP 状态码 | 错误类型 | 处理方式 |
|-----------|---------|---------|
| 401 | 认证失败 | 验证 Email 和 API Token 是否正确 |
| 403 | 权限不足 | 检查用户是否有访问该工作项的权限 |
| 404 | 工作项不存在 | 确认工作项 Key（如 MOS-2590）是否正确 |
| 429 | 请求过于频繁 | 等待 1 分钟后重试 |
| 500 | 服务器错误 | 检查 Jira 实例是否正常；稍后重试 |

**错误响应示例：**
```json
{
  "errorMessages": [
    "Issue does not exist or you do not have permission to see it."
  ]
}
```

---

## 最佳实践

1. **缓存结果** — 短时间内重复使用同一工作项信息时，避免多次 API 调用
2. **错误处理** — 遇到 401/403/404 时停止流程，通知用户
3. **隐私保护** — 不在日志中输出完整 API Token；使用环境变量或密钥管理系统
4. **性能优化** — 仅请求必要的字段，使用 `fields` 参数减少响应体积

---

## 参考资源

- [Jira REST API v3 官方文档](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [API Token 管理](https://id.atlassian.com/manage-profile/security/api-tokens)
- [Jira 权限模型](https://confluence.atlassian.com/adminjiraserver/managing-permissions-938847107.html)
