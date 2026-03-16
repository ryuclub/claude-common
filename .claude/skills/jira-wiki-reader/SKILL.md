---
name: jira-wiki-reader
description: 读取和解析 Jira Confluence Wiki 文档。通过 REST API 获取页面内容、历史版本、树形结构等信息。当用户需要获取项目规范文档、技术决策记录、API 文档、团队知识库、设计文档、查询 Wiki 页面时使用。
license: Proprietary
metadata:
  author: Mosavi Team
  version: "1.0"
  project: MOS-2590
compatibility: 需要访问互联网和 Confluence 实例；需要 curl 或 HTTP 客户端库；需要 Jira API Token 认证
---

# Jira Wiki（Confluence）读取器

## 概述

通过 Confluence REST API 读取和解析 Wiki 文档。支持获取页面内容、历史版本、空间结构等信息。

**适用场景：**
- 获取项目规范和标准文档
- 阅读技术决策记录（ADR）
- 获取 API 文档和接口规范
- 查询团队知识库
- 引用设计文档作为参考

---

## 快速开始

### 基本信息

| 参数 | 值 |
|------|-----|
| **API 版本** | v2（Confluence 标准） |
| **基础 URL** | `https://mosavi.atlassian.net/wiki/rest/api` |
| **认证方式** | Basic Auth（邮箱:API Token） |
| **响应格式** | JSON / HTML |

### 支持的输入格式

本 Skill 支持以下 3 种输入格式：

1. **Wiki URL**（推荐）
   ```
   https://mosavi.atlassian.net/wiki/spaces/SCRUM/pages/16941207
   ```
   → 自动解析 spaceKey=SCRUM, pageId=16941207

2. **页面标题**
   ```
   "MOS-2590 架构设计方案"
   ```
   → 搜索匹配该标题的页面

3. **Page ID**（高级）
   ```
   16941207
   ```
   → 直接获取指定页面

### 常用端点

```
获取页面内容:
GET /api/v2/pages/{pageId}

按标题搜索页面:
GET /api/v2/pages?status=current&title={title}&spaceKey={spaceKey}

获取页面树形结构:
GET /api/v2/pages/{pageId}/children

获取页面版本历史:
GET /api/v2/pages/{pageId}/versions

获取空间内容:
GET /api/v2/spaces/{spaceKey}/pages
```

---

## 认证：Basic Auth

同 Jira Issue Reader，使用邮箱 + API Token 进行认证

**curl 命令格式：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages" \
  --header "Accept: application/json"
```

---

## 读取 Wiki 页面

### 方式 1：从 Wiki URL 提取和获取

**输入 Wiki URL：**
```
https://mosavi.atlassian.net/wiki/spaces/SCRUM/pages/16941207
```

**自动解析：**
1. 提取 `spaceKey` = SCRUM
2. 提取 `pageId` = 16941207

**读取页面内容：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/16941207?body-format=view" \
  --header "Accept: application/json"
```

**示例调用：**
```
/jira-wiki-reader https://mosavi.atlassian.net/wiki/spaces/SCRUM/pages/16941207
```

---

### 方式 2：按页面 ID 获取（高级）

**直接提供 Page ID：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/{pageId}?body-format=storage" \
  --header "Accept: application/json"
```

**响应示例：**
```json
{
  "id": "123456",
  "type": "page",
  "status": "current",
  "title": "MOS-2590 架构设计方案",
  "space": {
    "key": "MOSAVI",
    "name": "Mosavi 项目"
  },
  "body": {
    "storage": {
      "value": "<h1>架构设计方案</h1><p>详细内容...</p>",
      "representation": "storage"
    }
  },
  "version": {
    "number": 5,
    "createdDate": "2026-03-16T15:00:00.000+0800"
  }
}
```

### 方式 3：按标题搜索页面

**搜索指定标题的页面：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages?title=MOS-2590%20架构设计&status=current&spaceKey=MOSAVI" \
  --header "Accept: application/json"
```

**提取页面 ID：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages?title=MOS-2590%20架构设计&status=current&spaceKey=MOSAVI" \
  --header "Accept: application/json" | jq '.results[0].id'
```

**示例调用：**
```
/jira-wiki-reader "MOS-2590 架构设计方案"
```

---

## 解析 Wiki 内容

### HTML 到 Markdown 转换

**获取 HTML 格式内容：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/{pageId}?body-format=view" \
  --header "Accept: application/json"
```

**转换为易读的纯文本：**
1. 获取 `body.view.value` 字段（HTML 格式）
2. 移除 HTML 标签
3. 处理 Confluence 特定标记（表格、代码块等）

**常见 Confluence 标签：**
```html
<!-- 标题 -->
<h1>标题 1</h1>
<h2>标题 2</h2>

<!-- 代码块 -->
<ac:structured-macro ac:name="code">...</ac:structured-macro>

<!-- 表格 -->
<table><tr><td>单元格</td></tr></table>

<!-- 列表 -->
<ul><li>列表项</li></ul>
```

---

## 获取页面树形结构

**获取页面的子页面：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/{pageId}/children?limit=50" \
  --header "Accept: application/json"
```

**递归遍历文档树：**
```bash
# 获取指定空间的所有页面
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/spaces/MOSAVI/pages?limit=100" \
  --header "Accept: application/json" | jq '.results[] | {id, title, status}'
```

---

## 获取页面版本历史

**查看页面的所有版本：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/{pageId}/versions" \
  --header "Accept: application/json"
```

**响应示例：**
```json
{
  "results": [
    {
      "number": 5,
      "createdDate": "2026-03-16T15:00:00.000+0800",
      "createdBy": {
        "email": "author@mosavi.com",
        "displayName": "张三"
      },
      "message": "更新架构图"
    },
    {
      "number": 4,
      "createdDate": "2026-03-15T10:00:00.000+0800",
      "message": "初始版本"
    }
  ]
}
```

**获取指定版本的内容：**
```bash
curl -u "EMAIL:API_TOKEN" \
  --request GET \
  --url "https://mosavi.atlassian.net/wiki/rest/api/v2/pages/{pageId}/versions/{versionNumber}" \
  --header "Accept: application/json"
```

---

## 常见错误处理

| HTTP 状态码 | 错误类型 | 处理方式 |
|-----------|---------|---------|
| 401 | 认证失败 | 验证 Email 和 API Token |
| 403 | 权限不足 | 检查用户是否有访问该页面的权限 |
| 404 | 页面不存在 | 确认页面 ID 或标题是否正确 |
| 429 | 请求过于频繁 | 等待 1 分钟后重试 |

---

## 最佳实践

1. **缓存策略** — 频繁访问的文档可缓存 24 小时，避免重复 API 调用
2. **内容解析** — 优先使用 `body-format=view`（HTML），再进行清理和转换
3. **权限检查** — 404 可能意味着无权访问，而非页面不存在
4. **批量查询** — 使用 `limit` 参数控制单次响应大小，避免超时
5. **隐私保护** — API Token 不应出现在日志或版本控制中

---

## 参考资源

- [Confluence REST API 官方文档](https://developer.atlassian.com/cloud/confluence/rest/v2/)
- [Confluence 内容格式](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)
- [Jira + Confluence 集成](https://www.atlassian.com/software/confluence/integrations)
