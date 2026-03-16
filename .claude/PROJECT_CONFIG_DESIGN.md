# 项目 AI 配置架构重设计

分析 `ai.project` 的问题并提出改进方案。

---

## 问题诊断

### 当前 `ai.project` 的问题

```
ai.project/
├── .claude/CLAUDE.md ................. ❌ 文件太多重复了
├── .claude-plugin/ .................. ❌ 实际没用上
├── config/CONFIG.env ................ ❌ 巨大的环境变量文件
├── standards/ ...................... ❌ 重复了 .claude/guidelines 的逻辑
├── templates/ ...................... ❌ 散落在这里，没有体系
├── skills/ ......................... ❌ 没有实际内容
├── overview-example.md ............. ❌ 过时的示例
└── README.md ....................... ❌ 列了一堆"指导"但太分散
```

### 根本问题

1. **职责不清** — 什么应该在 `.claude/` 里，什么应该在 `ai.project/` 里？
   - 通用 Guidelines → `.claude/`
   - 项目特定 Standards → `ai.project/`
   - 但实际上很多内容是混合的

2. **文件散落** — 没有清晰的分类和导航
   - 配置、规范、流程、模板混在一起
   - 新成员不知道从哪里开始

3. **内容冗余** — 很多规范被重复定义
   - `.claude/guidelines/01-workflow.md` 定义通用工作流
   - `ai.project/standards/03-project-workflow.md` 又定义项目工作流
   - 关系不清晰

4. **敏感信息混乱** — CONFIG.env 太大，包含了太多非关键信息
   - 真正敏感的（API Token）和非敏感的（项目代码）混在一起
   - 难以管理版本控制

5. **导航不清** — README.md 洋洋洒洒但没有优先级
   - 列出 4 个主要文件，但实际有 10+ 个需要理解
   - 没有"快速开始"路径

---

## 理想的 `ai.project` 应该是什么？

### 核心理念

```
ai.project/ 是 .claude/ 的补充和扩展，不是重复

分工：
  .claude/        — 通用、可复用、稳定的规范和 skills
  ai.project/     — 项目特定、变化频繁、敏感信息、流程细化
```

### 精简版结构（推荐）

```
ai.project/
├── .claude/
│   ├── CLAUDE.md ..................... 项目特定规范导航（核心）
│   └── hooks/
│       └── sync-guidelines.sh ........ 可选：同步远程规范
│
├── config/
│   ├── sensitive.env ................. 🔐 仅开发者本地（.gitignore）
│   └── infrastructure.md ............ 基础设施参考（非敏感）
│
├── standards/
│   ├── 01-go-coding-standard.md .... Go 编码规范（项目特定实现）
│   └── README.md ................... 导航
│
├── workflows/ ...................... 新增：项目工作流脚本
│   ├── Makefile ................... 开发常用命令
│   ├── scripts/
│   │   ├── deploy-canary.sh ....... 灰度部署
│   │   ├── run-tests.sh .......... 运行测试
│   │   └── pre-commit.sh ........ Git hook
│   └── README.md
│
├── templates/ .................... 项目模板
│   ├── jira/
│   │   ├── issue.template.md ..... Jira Issue 模板
│   │   └── epic.template.md ...... Epic 模板
│   ├── design/
│   │   └── phase-design.template.md
│   └── README.md
│
├── README.md ..................... 快速导航（简化）
└── QUICK_START.md ................ 新增：快速开始指南
```

---

## 改进方案

### 问题 1：职责不清 → 分层澄清

**新的分工原则：**

| 内容类型 | `.claude/` | `ai.project/` | 说明 |
|---------|-----------|---------------|------|
| 通用工作流 | ✅ 01-workflow.md | ❌ | 所有项目都遵循的 7 步工作流 |
| 项目工作流 | ❌ | ✅ workflows/Makefile | 这个项目特定的命令、脚本、流程 |
| 编码原则 | ✅ 04-coding-principles.md | ❌ | 语言无关的编码原则 |
| Go 编码标准 | ❌ | ✅ standards/01-go-coding-standard.md | Go 项目的具体实现 |
| 设计文档框架 | ✅ 02-design-document.md | ❌ | 通用的设计文档结构 |
| 项目设计文档 | ❌ | `/design/` | MOS-2590.md、ROADMAP.md 等 |
| Git Hook | ❌ | ✅ workflows/scripts/pre-commit.sh | 项目特定的 Git hooks |
| Jira 模板 | ❌ | ✅ templates/jira/ | 这个项目的 Jira 工作项模板 |

---

### 问题 2：文件散落 → 分类重组

**新的分类逻辑：**

```
├── .claude/ .................. AI 配置（导航和脚本）
├── config/ .................. 配置文件和参考
├── standards/ .............. 项目规范（与通用 Guidelines 的关系）
├── workflows/ .............. 可执行的工作流和脚本
├── templates/ .............. 项目模板集合
└── docs/ (可选) .......... 其他项目文档
```

**每个目录的职责：**

```
.claude/
  └─ CLAUDE.md ............. 项目规范的导航入口（告诉 AI"项目有什么规范"）
  └─ hooks/ ............... 自动化脚本（如同步远程规范）

config/
  └─ sensitive.env ........ 🔐 敏感配置（API Token、数据库密码）
  └─ infrastructure.md .... 非敏感参考（项目代码、AWS 区域等）

standards/
  └─ 01-go-coding-standard.md ..... 项目特定实现（补充 .claude/04-coding-principles.md）
  └─ README.md ........................ 说明与通用规范的关系

workflows/
  └─ Makefile ..................... 日常开发命令（make test, make lint, make deploy）
  └─ scripts/ ..................... 项目特定脚本（部署、测试、hooks）
  └─ README.md .................... 可用命令列表

templates/
  └─ jira/ ....................... Jira 工作项模板
  └─ design/ ..................... 设计文档模板
  └─ README.md ................... 模板使用指南

README.md ........................ 快速导航（简化，只列关键文件）
QUICK_START.md .................. 新增：快速开始路径
```

---

### 问题 3：内容冗余 → 明确关系

**新的规范关系图：**

```
通用 Guidelines（.claude/guidelines/）
  ├─ 01-workflow.md（通用工作流）
  │   ↓ 项目细化
  │   ai.project/workflows/README.md + scripts/
  │
  ├─ 02-design-document.md（设计框架）
  │   ↓ 项目示例
  │   /design/MOS-2590.md, ROADMAP.md
  │
  ├─ 03-branch-management.md（Git 规范）
  │   ↓ 项目自动化
  │   ai.project/workflows/scripts/pre-commit.sh
  │
  ├─ 04-coding-principles.md（编码原则）
  │   ↓ 项目实现
  │   ai.project/standards/01-go-coding-standard.md
  │
  └─ 05-review-checklist.md（审查清单）
      ↓ 项目实施
      ai.project/workflows/scripts/pre-commit.sh (自动检查)
```

**改进后的 standards/ 职责：**

```
不再是"复述通用规范"，而是"说明项目如何实现通用规范"

ai.project/standards/01-go-coding-standard.md
  内容：
    1. "通用编码原则（链接到 .claude/04-coding-principles.md）"
    2. "Go 项目的具体实现：
       - 包结构
       - 命名规则
       - 接口设计
       - 错误处理"
    3. "相关工具和自动化（Makefile、pre-commit hook）"
```

---

### 问题 4：敏感信息混乱 → 分离管理

**新的配置分离策略：**

```
config/sensitive.env（🔐 .gitignore）
  ├─ JIRA_EMAIL=...
  ├─ JIRA_API_TOKEN=...
  ├─ AWS_ACCESS_KEY=...
  ├─ DB_PASSWORD=...
  └─ ... 只有真正敏感的信息

config/infrastructure.md（✅ 版本控制）
  ├─ 项目代码：MOS-2590
  ├─ AWS 区域：us-east-1
  ├─ ECR 仓库名：mosavi-firebase-to-go
  ├─ ECS 集群名：mosavi-prod
  ├─ RDS 端点：db.mosavi.internal
  ├─ DynamoDB 表：...
  └─ ... 参考信息，便于理解配置结构
```

**好处：**
- ✅ sensitive.env 小而专，易于加密和备份
- ✅ infrastructure.md 可版本控制，便于 Code Review
- ✅ 清晰分离敏感 vs 非敏感

---

### 问题 5：导航不清 → 简化和分层

**新的导航策略：**

```
README.md（简洁版，只列 "这个项目有什么"）
  ├─ 快速导航 3 行
  ├─ 核心文件 5 个
  └─ "更多详情见下面的指导"

QUICK_START.md（新增："怎么开始"）
  ├─ 环境配置
  ├─ 常用命令（Makefile）
  ├─ 开发流程
  └─ 相关文档链接

.claude/CLAUDE.md（详细："项目规范完整导航"）
  ├─ 项目概览
  ├─ 项目特定规范（4 个标准）
  ├─ 可用工作流和脚本
  └─ 模板使用
```

**三层导航：**
```
首次接触项目
  ↓
README.md（了解项目"是什么"）
  ↓
QUICK_START.md（快速上手"怎么做"）
  ↓
.claude/CLAUDE.md（深入理解"为什么这样"）
  ↓
各子文档（detailed reference）
```

---

## 具体实施方案

### 方案 A：大改造（推荐）

**目标：** 重新组织整个 `ai.project`，建立清晰的分层结构

**阶段：**

1. **第 1 阶段：新增和调整（0.5 天）**
   ```bash
   # 新增目录结构
   mkdir -p ai.project/workflows/scripts
   mkdir -p ai.project/templates/jira
   mkdir -p ai.project/templates/design
   mkdir -p ai.project/config

   # 新增文件
   touch ai.project/QUICK_START.md
   touch ai.project/config/infrastructure.md
   ```

2. **第 2 阶段：迁移和重写（1-2 天）**
   - `config/CONFIG.env` → 分离为 `config/sensitive.env` + `config/infrastructure.md`
   - `standards/` → 重写为关联通用规范的项目实现
   - `templates/jira-templates.md` → 拆分为 `templates/jira/issue.template.md` 等
   - 新增 `workflows/Makefile` 和脚本集合

3. **第 3 阶段：重写导航文件（0.5 天）**
   - 简化 `README.md`（只列核心 5 个文件）
   - 新增 `QUICK_START.md`（快速上手指南）
   - 重写 `.claude/CLAUDE.md`（项目规范完整导航）

4. **第 4 阶段：验证和优化（0.5 天）**
   - 检查所有链接有效性
   - 测试新成员快速上手流程
   - 收集反馈并调整

**总耗时：** 2-3 天

---

### 方案 B：渐进式（保守）

**目标：** 在当前结构基础上逐步改进

**步骤：**

1. **今天：** 新增 `QUICK_START.md`（快速上手）
   - 不改变现有结构
   - 只是增加一个入口

2. **本周：** 拆分 `config/CONFIG.env`
   - 创建 `config/sensitive.env` 和 `config/infrastructure.md`
   - 更新 `.gitignore`

3. **下周：** 重写 `standards/` 中的规范
   - 添加"与通用规范的关系"段落
   - 说明项目如何实现通用规范

4. **两周后：** 新增 `workflows/` 目录和脚本
   - Makefile
   - Git hook 脚本
   - 部署脚本

5. **三周后：** 整理 `templates/` 并新增模板
   - Jira 模板
   - 设计文档模板

**总耗时：** 3 周（分散改进）

---

## 推荐结构清单

```
ai.project/
│
├── 📋 QUICK_START.md ..................... ⭐ 快速开始（新增）
│   ├─ 2 分钟快速上手
│   ├─ 环境配置
│   ├─ 常用 make 命令
│   └─ 后续推荐阅读
│
├── 📖 README.md ......................... 简化版导航
│   ├─ 项目概览（1 段）
│   ├─ 核心文件（5 个）
│   └─ "详见 QUICK_START.md 或 .claude/CLAUDE.md"
│
├── 🔧 .claude/
│   ├─ CLAUDE.md ...................... ⭐ 项目规范导航（详细版）
│   │   ├─ 项目特定规范 (4 个 standards)
│   │   ├─ 可用工作流和脚本
│   │   ├─ 模板使用
│   │   └─ 配置参考
│   │
│   └─ hooks/
│       └─ sync-guidelines.sh ........ 可选：同步远程规范
│
├── 📦 config/
│   ├─ sensitive.env .................. 🔐 敏感配置（.gitignore）
│   │   ├─ JIRA_EMAIL
│   │   ├─ JIRA_API_TOKEN
│   │   ├─ AWS_ACCESS_KEY
│   │   └─ DB_PASSWORD
│   │
│   └─ infrastructure.md ............ 非敏感参考
│       ├─ 项目代码
│       ├─ AWS 区域
│       ├─ 资源名称
│       └─ 通用信息
│
├── 📐 standards/
│   ├─ 01-go-coding-standard.md .... Go 实现（补充通用原则）
│   ├─ 02-testing-framework.md .... 测试框架
│   ├─ 03-project-workflow.md .... 项目工作流细化
│   ├─ 04-ci-cd-pipeline.md ..... CI/CD 管道
│   └─ README.md ................. 与通用规范的关系
│
├── 🔄 workflows/
│   ├─ Makefile .................... ⭐ 日常开发命令
│   │   ├─ make lint
│   │   ├─ make test
│   │   ├─ make build
│   │   ├─ make deploy-canary
│   │   └─ make monitor
│   │
│   ├─ scripts/
│   │   ├─ pre-commit.sh ........ Git pre-commit hook
│   │   ├─ deploy-canary.sh .... 灰度部署脚本
│   │   ├─ run-tests.sh ....... 运行全套测试
│   │   └─ monitor.sh ......... 监控脚本
│   │
│   └─ README.md ................ 可用命令参考
│
├── 📝 templates/
│   ├─ jira/
│   │   ├─ issue.template.md ... Jira Issue 模板
│   │   ├─ epic.template.md ... Epic 模板
│   │   └─ subtask.template.md  Subtask 模板
│   │
│   ├─ design/
│   │   ├─ phase-design.template.md ... Phase 设计模板
│   │   └─ service-design.template.md  Service 设计模板
│   │
│   └─ README.md ............... 模板使用指南
│
└── (可选) docs/
    └─ 其他项目文档
```

**核心文件（必读）：**
1. `QUICK_START.md` — 快速上手（2 分钟）
2. `README.md` — 项目概览（5 分钟）
3. `.claude/CLAUDE.md` — 详细导航（10 分钟）
4. `config/infrastructure.md` — 配置参考（按需）
5. `workflows/README.md` — 可用命令（按需）

---

## 关键改进点

### 1. 明确的职责分工
```
.claude/guidelines/ ← 通用、可复用、不含项目敏感信息
ai.project/standards/ ← 项目特定、敏感信息、项目实现
ai.project/workflows/ ← 可执行脚本和命令
ai.project/config/ ← 配置和参考信息
```

### 2. 简化的导航
```
README.md（简洁）
  ↓
QUICK_START.md（快速路径）
  ↓
.claude/CLAUDE.md（完整导航）
  ↓
各子文件（详细参考）
```

### 3. 分离的配置管理
```
sensitive.env（🔐 .gitignore）← API Token、密码
infrastructure.md（✅ 版本控制）← 参考信息
```

### 4. 可执行的工作流
```
Makefile + scripts/ ← 项目特定的日常命令
```

### 5. 系统化的模板
```
templates/ ← 集中管理所有项目模板
```

---

## 我的建议

**立即做（今天）：**
1. 新增 `QUICK_START.md`
2. 新增 `workflows/Makefile` 或 `workflows/README.md`
3. 新增 `config/infrastructure.md` 参考

**本周做：**
1. 拆分 `config/CONFIG.env` → `sensitive.env` + `infrastructure.md`
2. 整理 `templates/` 目录结构
3. 简化 `README.md`

**下周做：**
1. 重写 `standards/` 中的规范（明确与通用规范的关系）
2. 重写 `.claude/CLAUDE.md`（项目规范完整导航）

**结果：** `ai.project` 从"丑陋混乱"变成"清晰专业"

---

**最后更新：** 2026-03-16

