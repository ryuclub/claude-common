# Claude 通用规范库

本仓库包含所有项目通用的 Claude Code 规范、Skills、配置模板。

项目会**自动从此仓库同步**规范和 Skills 到本地缓存（`.claude/.remote-cache/`）。

---

## 📚 通用规范（Guidelines）

7 个跨项目复用的开发规范：

| 文件 | 说明 |
|------|------|
| [01-workflow.md](./guidelines/01-workflow.md) | 9 步完整开发工作流（需求→设计→分支→实现→审查→提交→PR→审查回复→整理） |
| [02-design-document.md](./guidelines/02-design-document.md) | 设计文档编写指南和审查标准 |
| [03-branch-management.md](./guidelines/03-branch-management.md) | Git 分支命名、base 分支选择、分支生命周期管理 |
| [04-coding-principles.md](./guidelines/04-coding-principles.md) | 语言无关的编码原则（命名、组织、错误处理） |
| [05-review-checklist.md](./guidelines/05-review-checklist.md) | 代码审查清单和质量检查标准 |
| [06-pre-commit-review.md](./guidelines/06-pre-commit-review.md) | 提交前审查清单（7 项检查） |
| [07-jira-conventions.md](./guidelines/07-jira-conventions.md) | JIRA 工单约定和最佳实践 |

---

## 🛠️ 通用 Skills

4 个跨项目复用的能力工具：

| Skill | 说明 |
|-------|------|
| [jira-issue-reader](./skills/jira-issue-reader/) | 读取和分析 Jira 工作项 |
| [jira-wiki-reader](./skills/jira-wiki-reader/) | 读取和解析 Confluence Wiki 文档 |
| [jira-manage-ticket](./skills/jira-manage-ticket/) | 创建、更新、删除 JIRA 工单（CRUD） |
| [pr-creator](./skills/pr-creator/) | 自动生成 PR 描述和创建 PR |

详见 [Skills 总览](./skills/README.md)

---

## 🔄 项目如何使用

### 自动同步流程

```
项目启动
  ↓
.claude/settings.json 触发 SessionStart hook
  ↓
.claude/hooks/auto-load.sh 执行
  ↓
git clone/pull claude-common → .claude/.remote-cache/
  ↓
AI 自动加载规范和 Skills
  ↓
开始工作
```

### 规范加载逻辑

| 场景 | 加载源 |
|------|-------|
| 任何任务开始 | `guidelines/01-workflow.md` |
| 编码或代码审查 | `项目的 standards/01-go-coding-standard.md` |
| 测试相关 | `项目的 standards/02-testing-framework.md` |
| Git/PR/分支 | `guidelines/03-branch-management.md` |
| 设计文档创建 | `guidelines/02-design-document.md` |

---

## 📂 仓库结构

```
claude-common/
├── guidelines/ ................. 7 个通用规范
├── skills/ ..................... 4 个通用 Skills
├── CLAUDE.md ................... 本文件（通用库入口）
├── settings.json .............. 通用配置模板
├── README.md ................... 项目说明
├── hooks/ ...................... 辅助脚本
└── .git/ ....................... Git 仓库

项目同步后（.claude/.remote-cache/）：
├── guidelines/ ................ 规范文件
├── skills/ .................... Skills 目录
├── CLAUDE.md
├── settings.json
└── ...
```

---

## 🚀 快速开始

### 添加到新项目

1. 在项目的 `.claude/hooks/auto-load.sh` 中配置：
```bash
REMOTE_REPO="https://github.com/ryuclub/claude-common.git"
```

2. 项目启动时 hook 自动同步

3. 规范和 Skills 可在 `.claude/.remote-cache/` 中使用

### 更新规范

1. 在此仓库修改规范文件
2. 提交并推送到 main 分支
3. 项目会在 24h 内自动拉取最新版本（或手动删除 `.sync` 文件强制更新）

---

## ✅ 版本控制

**提交到 Git：**

- `guidelines/` — 所有规范文件
- `skills/` — 所有 Skills
- `CLAUDE.md` — 本文档
- `settings.json` — 配置模板
- `hooks/` — 辅助脚本

**不提交到 Git：**

- 项目生成的缓存（`.claude/.remote-cache/` 在各项目中）

---

## 🔗 相关文档

- [Guidelines 总览](./guidelines/README.md)
- [Skills 总览](./skills/README.md)

---

**最后更新：** 2026-03-16

本仓库的目的：为所有项目提供一套统一的、可复用的规范和工具。
