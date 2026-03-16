# jira-manage-ticket

通用 JIRA 工单管理 Skill — 支持 CRUD 操作和高级搜索。

## 目录

- [快速开始](#快速开始)
- [功能列表](#功能列表)
- [使用示例](#使用示例)
- [API 参考](#api-参考)
- [项目集成](#项目集成)

## 快速开始

### 配置凭证

脚本会按以下优先级查找凭证：

1. **环境变量** — `ATLASSIAN_USERNAME`, `ATLASSIAN_API_KEY`, `ATLASSIAN_DOMAIN`（由项目启动时加载）
2. **Skill 目录** — `.env` 文件（手动创建，仅在无项目配置时）

#### 推荐方案：项目 claude.env（自动加载）

项目启动时会自动加载 `.claude/config/claude.env` 中的凭证：

```bash
# 复制模板
cp .claude/config/claude.env.example .claude/config/claude.env

# 编辑填入凭证
ATLASSIAN_USERNAME=your-email@example.com
ATLASSIAN_API_KEY=your-api-token
ATLASSIAN_DOMAIN=your-domain.atlassian.net
```

#### 备选方案：Skill 目录的 `.env`（如无项目配置）

```bash
# 仅在项目无 claude.env 时需要
cp .claude/.remote-cache/.claude/skills/jira-manage-ticket/.env.example \
   .claude/.remote-cache/.claude/skills/jira-manage-ticket/.env
```

### 基本使用

```bash
# 获取工单
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py get MOS-1234

# 创建工单
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py create-task "Title" "Description" 8 "任务"

# 查看所有可用命令
python3 .claude/.remote-cache/.claude/skills/jira-manage-ticket/scripts/jira_api.py
```

## 功能列表

| 命令 | 用途 | 示例 |
|------|------|------|
| `get` | 获取工单详情 | `get MOS-1234` |
| `create-task` | 创建独立工单 | `create-task "Title" "Desc" 8 "任务"` |
| `create` | 创建子工单 | `create MOS-1234 "Subtask" "Desc"` |
| `bulk-create` | 批量创建子工单 | `bulk-create MOS-1234 '[...]'` |
| `update` | 更新工单字段 | `update MOS-1234 '{"summary":"New"}'` |
| `delete` | 删除工单 | `delete MOS-1234` |
| `transition` | 变更状态 | `transition MOS-1234 "进行中"` |
| `search` | JQL 搜索 | `search 'project = MOS'` |

## 使用示例

### 创建工单

```bash
# 创建任务
python3 scripts/jira_api.py create-task \
  "实现用户认证" \
  "完成 OAuth2 集成" \
  8 \
  "故事"
```

### 创建子工单

```bash
# 在 Epic 下创建子任务
python3 scripts/jira_api.py create MOS-100 "单元测试" "编写认证模块的单元测试"
```

### 批量创建

```bash
python3 scripts/jira_api.py bulk-create MOS-100 '[
  {"summary": "API 实现"},
  {"summary": "单元测试"},
  {"summary": "集成测试", "estimate_hours": 4}
]'
```

### 搜索工单

```bash
# 查找我的所有任务
python3 scripts/jira_api.py search 'assignee = currentUser() AND project = MOS'

# 查找特定 Epic 下的子任务
python3 scripts/jira_api.py search 'parent = MOS-100 AND type = Subtask'
```

## API 参考

详见 [SKILL.md](./SKILL.md)

## 项目集成

### 在项目中使用

```bash
# 项目的 Makefile 或脚本中
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create-task "任务" "描述"
```

### 项目特化配置

在项目中创建包装脚本 `.claude/scripts/create-jira-task.sh`：

```bash
#!/bin/bash
# 项目特化的工单创建脚本

PROJECT_KEY="MOS"
TEAM_ID="your-team-id"

python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py "$@"
```

## 目录结构

```
jira-manage-ticket/
├── SKILL.md ......................... Skill 文档和 API 参考
├── README.md ........................ 本文件
├── .env.example ..................... 凭证模板
├── scripts/
│   └── jira_api.py ................. JIRA API 脚本
└── references/
    └── api_examples.md ............. REST API 示例
```

## 环境配置

在 `.env` 中设置：

```bash
ATLASSIAN_USERNAME=your-email@example.com
ATLASSIAN_API_KEY=your-api-token
ATLASSIAN_DOMAIN=your-domain.atlassian.net
```

**获取 API Token：** https://id.atlassian.com/manage-profile/security/api-tokens

## 常见问题

**Q: 支持哪些项目？**
A: 默认支持 `MOS` 项目，其他项目可通过重写 `api.PROJECT_KEY` 和 `api.ISSUE_TYPE_IDS` 支持。

**Q: 是否支持自定义字段？**
A: 支持。参看 SKILL.md 中的"项目特化"部分。

**Q: 如何批量创建？**
A: 使用 `bulk-create` 命令传入 JSON 数组。

## 更多信息

- [JIRA REST API 官方文档](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [项目集成指南](./SKILL.md#项目特化)
