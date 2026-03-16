# AI 指南

本文件由 AI 助手自动读取，作为项目级别的配置入口。
开始工作前请参考以下规则文档。

## AI 行为规则

- **输出语言**：始终使用中文输出（包括 JIRA 评论、commit message、PR 内容）
- **JIRA 评论格式**：使用 JIRA Wiki 标记，禁止使用 Markdown。规则：`h2.`/`h3.` 标题、`#` 有序列表、`*` 无序列表、`{{code}}` 行内代码、`*text*` 粗体
- **commit message**：不添加 `Co-Authored-By` 等 AI 相关署名
- **PR 内容**：不添加 AI 工具相关说明或链接

## 规则文档

- [开发工作流](.claude/guidelines/workflow.md)
- [设计文档编写指南](.claude/guidelines/design-document.md) ⭐ 工作流第 2 步参考
- [分支管理规则](.claude/guidelines/branch.md)
- [编码规约](.claude/guidelines/coding.md)
- [提交前审查基准](.claude/guidelines/pre-commit-review.md)

## 可用的 Skills

在工作中可通过 `/<skill-name>` 显式调用，或 AI 在工作流中自动识别使用。

### 通用 Skills（跨项目复用）

- [Jira Issue Reader](.claude/skills/jira-issue-reader/SKILL.md) — 读取和分析 Jira 工作项
  - 调用方式：`/jira-issue-reader MOS-XXXX`
  - 自动触发：工作流 Step 1（接收需求）中读取票号时
- [Jira Wiki Reader](.claude/skills/jira-wiki-reader/SKILL.md) — 读取和解析 Jira Confluence Wiki
  - 调用方式：`/jira-wiki-reader <URL|标题|PageID>`
  - 自动触发：需要查询规范文档或设计文档时
- [PR Creator](.claude/skills/pr-creator/SKILL.md) — 自动生成 PR 描述和创建 PR
  - 调用方式：`/pr-creator`
  - 自动触发：创建 PR 或编写 PR 描述时

详见 [Skills 总览](.claude/skills/README.md)

### Skills 来源

- **通用 Skills**：由 `.claude/.claude-plugin/marketplace.json` 管理
  - 存储路径：`.claude/skills/`
  - 可复用：✅ 可直接复制到其他项目

- **项目特定 Skills**：由 `.claude-local/.claude-plugin/marketplace.json` 管理
  - 存储路径：`.claude-local/skills/`
  - 可复用：❌ 仅本项目使用

## 项目指导

项目特定的配置和指导文件集中管理在 `/.claude-local/` 目录下。

**⭐ 入口：** [项目特定指导](./..-local/CLAUDE.md) — 项目规范、standards、workflows

**详情：** [项目 README](./../.claude-local/README.md) — 项目配置、自动化规则、API 访问

---

## 核心规范（每个任务开始时遵循）

按照以下规范执行所有任务。规范分为两层：

### 1️⃣ 通用指南（所有项目适用）

详见 [通用开发指南](.claude/guidelines/README.md)

1. **[开发工作流](.claude/guidelines/01-workflow.md)** — 7 步工作流规范
   - 需求 → 设计 → 代码 → 测试 → 审查 → 部署 → 验收
   - 适用：所有任务开始时
   - **关键**：设计文档必须参考 [设计文档编写指南](.claude/guidelines/02-design-document.md)

2. **[分支管理规则](.claude/guidelines/03-branch-management.md)** — Git 分支和提交规范
   - 分支命名、提交规范、PR 流程
   - 适用：所有 Git 操作、PR 创建时

3. **[编码原则](.claude/guidelines/04-coding-principles.md)** — 语言无关的编码原则
   - 命名规则、代码组织、可读性、错误处理
   - 适用：所有代码编辑任务
   - 注：具体实现由下面的项目特定规范细化

4. **[代码审查清单](.claude/guidelines/05-review-checklist.md)** — 代码审查标准
   - 审查要点、质量检查
   - 适用：所有代码审查任务

### 2️⃣ 项目特定规范（仅本项目适用）

详见 [项目特定规范](./../.claude-local/standards/README.md) 或快速入口 [.claude-local/CLAUDE.md](./../.claude-local/CLAUDE.md)

1. **[Go 编码标准](./../.claude-local/standards/01-go-coding-standard.md)** — 本项目的 Go 编码规范
   - 项目结构、包组织、命名规则、接口设计、错误处理、日志、文档
   - 适用：所有代码编辑、代码审查任务
   - 补充：`.claude/guidelines/04-coding-principles.md`

2. **[Go 测试框架](./../.claude-local/standards/02-testing-framework.md)** — 本项目的测试规范
   - 单元测试、集成测试、性能基准、灰度测试、覆盖率要求
   - 适用：编写/修改代码、测试相关任务

3. **[项目工作流细化](./../.claude-local/standards/03-project-workflow.md)** — Mosavi 项目的工作流特化
   - 项目特定的工作流步骤、流程、工具链
   - 适用：所有项目任务（可选，如果与通用工作流有差异）

4. **[CI/CD 和自动化](./../.claude-local/standards/04-ci-cd-pipeline.md)** — 项目的自动化规则
   - CI/CD 流程、部署策略、灰度部署、自动回滚
   - 适用：代码提交、部署任务

---

---

## 🔍 配置加载机制

理解配置、规范和 skills 的发现流程：

**快速入门：** [LOADING_STRATEGY.md](.claude/LOADING_STRATEGY.md) — 速查表、决策树、行动计划

**深度阅读：**

- [CONFIG_LOADING.md](.claude/CONFIG_LOADING.md) — 启动流程、层级结构、发现流程
- [EXTERNAL_DISCOVERY.md](.claude/EXTERNAL_DISCOVERY.md) — 从 GitHub/共享位置动态发现 Skills
- [RULESET_LOADING.md](.claude/RULESET_LOADING.md) — 规范和流程的动态加载方案对比

**快速问答：**

- Q: 通用配置如何发现项目规范？
  A: 通过 CLAUDE.md 链接和项目特定的 `.claude-local/CLAUDE.md`
- Q: 项目特定的 skills 如何被加载？
  A: 通过 `.claude-local/.claude-plugin/settings.json` 和 marketplace.json（需 Claude Code 支持多 settings）
- Q: 相对路径如何工作？
  A: 所有路径相对于项目根目录；跨项目访问用 `../Mosavi-Push-Service/**`

---

## 自动触发规则

### Skills 自动调用

- **识别到 Jira 票号**（MOS-XXXX）→ 自动调用 `/jira-issue-reader`
- **提到 Wiki 文档**（URL/标题）→ 自动调用 `/jira-wiki-reader`
- **提到创建 PR** → 自动调用 `/pr-creator`

### 规范自动加载

- **开始任何任务** → 自动加载 `.claude/guidelines/01-workflow.md`（工作流指导）
- **编码或代码审查** → 自动加载 `.claude-local/standards/01-go-coding-standard.md`（Go 编码规范）
- **测试相关任务** → 自动加载 `.claude-local/standards/02-testing-framework.md`（测试框架）
- **分支、提交、PR** → 自动加载 `.claude/guidelines/03-branch-management.md`（分支管理）
- **设计文档创建** → 自动加载 `.claude/guidelines/02-design-document.md`（设计规范）

**原理：** AI 在对话开始时读取本 CLAUDE.md，看到这些规则和链接，在合适的任务场景中自动加载相应的规范。
