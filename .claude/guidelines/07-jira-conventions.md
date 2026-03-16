# JIRA 工单约定

## 项目信息

配置项目特定信息（需根据实际项目调整）：

- **项目 Key**: `<PROJECT-KEY>`（如 MOS、ABC 等）
- **工单 URL**: `https://<jira-domain>/browse/<PROJECT-KEY>-XXXX`
- **看板**: `https://<jira-domain>/jira/software/c/projects/<PROJECT-KEY>/boards/<board-id>`

## 工单类型

| 类型 | 用途 | 说明 |
|------|------|------|
| **Epic**（长篇故事） | 大功能/跨 Sprint 项目 | 通常跨越多个迭代，包含多个 Story |
| **Story**（故事） | 用户故事/功能 | 一个迭代内可完成的功能需求 |
| **Task**（任务） | 技术任务 | 不直接对应用户需求的技术工作（refactor、docs 等） |
| **Bug**（缺陷） | Bug 修复 | 产品中存在的问题/缺陷 |
| **Subtask**（子任务） | 细分任务 | 归属于 Story/Task/Bug 的细分工作 |

## 必填字段

创建工单时必须填写以下字段：

| 字段 | 示例 | 说明 |
|------|------|------|
| **标题** | "实现用户认证功能" | 清晰、简洁、不超过 80 字 |
| **描述** | 背景、需求、接受标准 | 使用 JIRA Wiki 格式 |
| **工单类型** | Story / Bug / Task | 根据内容选择 |
| **优先级** | High / Medium / Low | 根据紧急程度 |
| **经办人** | 创建人 | 分配给具体负责人 |
| **故事点/预估** | 5 / 8h | 估算工作量（可选） |

**项目特化字段** （根据实际项目配置）：

- `<custom-field-1>`: 说明（如"系统"、"修复版本"等）
- `<custom-field-2>`: 说明

## 工单创建脚本

如果项目配置了 `jira-manage-ticket` Skill，可使用脚本创建工单：

```bash
# 创建独立工单（Story/Task/Bug）
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create-task "<标题>" "<描述>" [预估工时h] [工单类型]

# 创建子工单
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py \
  create <PARENT-TICKET> "<标题>" "<描述>" [预估工时h]

# 获取工单信息
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py get <TICKET>

# 搜索工单（JQL）
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py \
  search "project = <PROJECT-KEY> AND assignee = currentUser()"

# 状态变更
python3 .claude/skills/jira-manage-ticket/scripts/jira_api.py \
  transition <TICKET> "进行中"
```

**配置：** 脚本需要 `.claude/skills/jira-manage-ticket/.env` 文件配置凭据

## JIRA 评论格式

JIRA 原生支持 **JIRA Wiki 标记**（不是 Markdown）：

| 要素 | 语法 | 示例 |
|------|------|------|
| 二级标题 | `h2. 标题` | h2. 实现方案 |
| 三级标题 | `h3. 标题` | h3. 技术细节 |
| 有序列表 | `# 项目` | # 第一步 |
| 无序列表 | `* 项目` | * 需求1 |
| 粗体 | `*text*` | *重要* |
| 斜体 | `_text_` | _示例_ |
| 行内代码 | `{{code}}` | {{User.id}} |
| 代码块 | `{code}...{code}` | {code}select * from users{code} |
| 链接 | `[text\|URL]` | [JIRA\|https://example.atlassian.net] |
| 引用 | `bq. 引用文字` | bq. 这是一个引用 |

**重要：** 在 JIRA 评论中禁止使用 Markdown，必须使用 Wiki 标记

## 工单与分支对应

一个工单对应一个分支，遵循如下映射：

```
Epic <PROJECT-KEY>-100
  ├─ Story <PROJECT-KEY>-101
  │   └─ feat/<PROJECT-KEY>-101-feature-name
  │       └─ Commit: feat(<PROJECT-KEY>-101): description
  │           └─ PR → <base-branch>
  │
  └─ Story <PROJECT-KEY>-102
      └─ fix/<PROJECT-KEY>-102-bug-fix
          └─ PR → <base-branch>
```

**规则：**
- 分支名必须包含工单号（`<PROJECT-KEY>-XXXX`）
- Commit message 必须包含工单号
- PR 的 base 分支由项目决定（通常 `main` 或 `develop`）

## 工单生命周期

**创建 → 进行中 → 审查 → 完成**

| 状态 | 触发条件 | 负责人 |
|------|---------|--------|
| **待办** | 工单创建 | 产品经理 |
| **进行中** | 开发人员开始实现 | 开发人员 |
| **代码审查** | PR 创建 | 评审人员 |
| **完成** | PR 合并 + 验收通过 | 产品经理 |
| **关闭** | 验收完成，无遗留问题 | 产品经理 |

## 最佳实践

1. **清晰的标题：** 使用动词开头，清晰表达工作内容
   - ✅ 好：实现用户登录认证功能
   - ❌ 差：登录相关修改

2. **详细的描述：** 使用 JIRA Wiki 格式，包含：
   - 背景和上下文
   - 需求/问题描述
   - 接受标准（AC）
   - 相关链接

3. **及时更新状态：** 反映实际进度
   - 开始工作时更改为"进行中"
   - 创建 PR 时更改为"代码审查"
   - PR 合并时标记为"完成"

4. **记录关键信息：** 在评论中记录重要决策、风险、变更
   - 使用 JIRA 评论而不是口头沟通
   - 便于后续追踪和知识积累

5. **关联相关工单：** 使用"链接"功能关联依赖工单
   - Epic 关联 Story
   - Story 关联 Subtask
   - 关联阻塞或被阻塞的工单
