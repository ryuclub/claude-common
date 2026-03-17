# jira-manage-ticket Skill

JIRA REST API 工单管理工具 - 支持创建、读取、更新、删除工单和状态转换。

## 功能概述

- ✅ **读取工单** — 获取工单信息和详情
- ✅ **创建工单** — 创建独立工单或子工单
- ✅ **批量创建** — 一次创建多个子工单
- ✅ **更新工单** — 修改标题、描述、分配人等
- ✅ **删除工单** — 删除工单
- ✅ **状态转换** — 变更工单状态
- ✅ **JQL 搜索** — 使用 JQL 查询工单

## 快速开始

### 1. 配置认证

项目启动时会自动加载 `.claude/config/claude.env` 中的凭证到环境变量。

**第一次配置：**

```bash
# 复制模板
cp .claude/config/claude.env.example .claude/config/claude.env

# 编辑填入凭证
vim .claude/config/claude.env
```

填入您的 Atlassian 凭证：

```bash
ATLASSIAN_USERNAME=your-email@example.com
ATLASSIAN_API_KEY=your-api-token
ATLASSIAN_DOMAIN=your-domain.atlassian.net
```

**如何获取 API Token：**
1. 访问 https://id.atlassian.com/manage-profile/security/api-tokens
2. 点击 "Create API token"
3. 复制生成的 token 到 `claude.env`

### 2. 使用脚本

```bash
# 获取工单
python3 scripts/jira_api.py get MOS-1234

# 创建工单
python3 scripts/jira_api.py create-task "工单标题" "描述内容" 8 "任务"

# 创建子工单
python3 scripts/jira_api.py create MOS-1234 "子任务标题" "描述"

# 批量创建子工单
python3 scripts/jira_api.py bulk-create MOS-1234 '[
  {"summary": "任务1"},
  {"summary": "任务2", "estimate_hours": 5}
]'

# 更新工单
python3 scripts/jira_api.py update MOS-1234 '{"summary": "新标题"}'

# 删除工单
python3 scripts/jira_api.py delete MOS-1234

# 状态转换
python3 scripts/jira_api.py transition MOS-1234 "进行中"

# JQL 搜索
python3 scripts/jira_api.py search 'project = MOS AND assignee = currentUser()'
```

## API 文档

### JiraAPI 类

#### 初始化

```python
from scripts.jira_api import JiraAPI

api = JiraAPI()
```

#### 常用方法

**获取工单**
```python
result = api.get("MOS-1234")
# 返回: {"key", "summary", "status", "issuetype", "assignee", ...}
```

**创建独立工单**
```python
result = api.create_task(
    summary="工单标题",
    description="工单描述",
    estimate_hours=8,
    issue_type="任务"  # 任务、故事、缺陷
)
# 返回: {"key": "MOS-2345", "self": "..."}
```

**创建子工单**
```python
result = api.create_subtask(
    parent_key="MOS-1234",
    summary="子任务标题",
    description="描述",
    estimate_hours=4,
    issue_type="任务"
)
```

**批量创建子工单**
```python
results = api.bulk_create_subtasks(
    parent_key="MOS-1234",
    subtasks=[
        {"summary": "任务1", "description": "描述1"},
        {"summary": "任务2", "estimate_hours": 5}
    ]
)
```

**更新工单**
```python
result = api.update("MOS-1234", {
    "summary": "新标题",
    "description": "新描述",
    "duedate": "2026-04-01"
})
```

**删除工单**
```python
result = api.delete("MOS-1234")
```

**状态转换**
```python
result = api.transition("MOS-1234", "进行中")
```

**JQL 搜索**
```python
results = api.search("project = MOS AND assignee = currentUser()")
```

## 项目特化

脚本支持在项目中重写以下配置（无需修改源代码）：

```python
api.PROJECT_KEY = "YourProject"
api.ISSUE_TYPE_IDS = {
    "长篇故事": "10000",
    "故事": "10006",
    "任务": "10007",
    "子任务": "10008",
    "缺陷": "10009",
}
api.TEAM_FIELD = "customfield_10001"
api.DEFAULT_TEAM_ID = "your-team-id"
api.SYSTEM_FIELD = "customfield_10037"
api.DEFAULT_SYSTEM = {"id": "10022"}
```

## 参考资料

- [JIRA REST API v3 文档](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [API 使用示例](./references/api_examples.md)

## 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `ATLASSIAN_USERNAME` | Atlassian 账户邮箱 | `user@example.com` |
| `ATLASSIAN_API_KEY` | API Token | `xxxxxxxxxxxx` |
| `ATLASSIAN_DOMAIN` | Atlassian 域名 | `your-domain.atlassian.net` |

## 故障排查

### 认证失败

**错误:** `Error 401: Unauthorized`

**原因:** API Token 错误或过期

**解决：**
1. 检查 `.env` 中的凭证是否正确
2. 在 https://id.atlassian.com/manage-profile/security/api-tokens 重新生成 token

### 项目不支持

**错误:** `不支持的项目 'YOUR-PROJECT'`

**原因:** 脚本中的 `ISSUE_TYPE_IDS` 仅配置了默认项目（MOS）

**解决：** 在项目中重写 `api.PROJECT_KEY` 和 `api.ISSUE_TYPE_IDS`

### 权限不足

**错误:** `Error 403: Forbidden`

**原因:** 当前用户无权限执行该操作

**解决：** 检查 JIRA 权限设置
