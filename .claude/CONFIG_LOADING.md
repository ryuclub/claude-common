# Claude Code 配置加载流程

本文档解释 Claude Code 如何在项目中发现和加载配置、规范和 skills。

---

## 启动流程

### 第 1 步：发现并加载 settings.json

Claude Code 在启动时，按以下顺序查找 `settings.json`：

```
工作目录及其父目录
  ↓
.claude/settings.json 存在？ ✅
  ↓
加载通用配置和 plugins（anthropic-agent-skills, claude-generic-skills 等）
```

**当前状态：**
- ✅ `.claude/settings.json` 存在，包含通用 permissions 和 plugins
- ✅ `settings.local.json` 存在（不提交），包含项目特定权限

### 第 2 步：发现并加载 CLAUDE.md

Claude Code **自动读取** 以下位置的 `CLAUDE.md`：

```
.claude/CLAUDE.md 存在？ ✅
  ↓
读取内容，解析所有链接
  ↓
通过链接发现规范、standards、skills 等
```

**CLAUDE.md 的作用：** 它是一份**导航清单**，让 AI 知道项目中有什么规范、standards 和 skills。

**当前内容：**
- ✅ 通用指南链接（5 个）
- ✅ 通用 skills 链接（3 个）
- ✅ 项目指导入口链接（指向 `ai.project/.claude/CLAUDE.md`）

### 第 3 步：发现项目特定规范

当 AI 通过 CLAUDE.md 发现 `ai.project/.claude/CLAUDE.md` 链接时：

```
[项目特定指导](../ai.project/.claude/CLAUDE.md) 被发现
  ↓
读取 ai.project/.claude/CLAUDE.md
  ↓
发现项目特定的 standards 和 skills
  ↓
根据需要自动加载相应规范
```

**当前状态：**
- ✅ `ai.project/.claude/CLAUDE.md` 已创建，包含项目特定规范链接
- ✅ `ai.project/standards/` 目录下有 4 个标准文档
- ⏳ `ai.project/skills/` 待实现项目特定 skills

### 第 4 步：加载 Plugins

#### 通用 Plugins
```json
// .claude/settings.json
"enabledPlugins": {
  "document-skills@anthropic-agent-skills": true,
  "example-skills@anthropic-agent-skills": true,
  "claude-api@anthropic-agent-skills": true,
  "generic-jira-tools@claude-generic-skills": true,
  "generic-git-tools@claude-generic-skills": true
}
```

**加载机制：**
1. 读取 `settings.json` 中的 `enabledPlugins`
2. 查找对应的 marketplace：`.claude-plugin/marketplace.json`（通用）
3. 根据 marketplace.json 加载 plugins

#### 项目特定 Plugins
```json
// ai.project/.claude-plugin/settings.json
"enabledPlugins": {
  "mosavi-project-skills": true
}
```

**加载机制：**
1. Claude Code 读取 `ai.project/.claude-plugin/settings.json`（如果支持）
2. 查找对应 marketplace：`ai.project/.claude-plugin/marketplace.json`
3. 根据 marketplace.json 加载项目特定 skills

⚠️ **注意：** 当前 Claude Code 可能不会自动读取 `ai.project/.claude-plugin/settings.json`。这需要 Claude Code 扩展功能支持。

---

## 配置层级

```
优先级从低到高：

┌─────────────────────────────────────────┐
│  1. 内置默认配置（Claude Code 内置）     │
├─────────────────────────────────────────┤
│  2. .claude/settings.json（通用）        │◄── 可版本控制
│     └─ 通用 plugins, permissions        │
├─────────────────────────────────────────┤
│  3. .claude/settings.local.json（本机）  │◄── 本机私有
│     └─ 跨项目权限（兄弟项目）            │
├─────────────────────────────────────────┤
│  4. ai.project/.claude-plugin/settings.json │◄── 项目特定（待支持）
│     └─ 项目特定 plugins                │
├─────────────────────────────────────────┤
│  5. CLI 参数（--permissions 等）         │◄── 临时覆盖
└─────────────────────────────────────────┘
```

---

## 规范发现流程

### 通用规范

```
.claude/CLAUDE.md 被读取
  ↓
链接：
  - [开发工作流](./guidelines/01-workflow.md)
  - [编码原则](./guidelines/04-coding-principles.md)
  - 等（通用指南）
  ↓
AI 根据需要加载相应规范
```

### 项目特定规范

```
.claude/CLAUDE.md 第 53 行：
  [项目特定指导](../ai.project/.claude/CLAUDE.md)
    ↓
ai.project/.claude/CLAUDE.md 被读取
  ↓
链接：
  - [Go 编码标准](../standards/01-go-coding-standard.md)
  - [测试框架](../standards/02-testing-framework.md)
  - [CI/CD 管道](../standards/04-ci-cd-pipeline.md)
  ↓
AI 根据需要加载相应规范
  （例如：编码时加载 Go 编码标准）
```

---

## Skills 发现流程

### 通用 Skills

```
.claude/settings.json 中：
  "enabledPlugins": {
    "generic-jira-tools@claude-generic-skills": true
  }
    ↓
.claude/.claude-plugin/marketplace.json 注册通用 skills
    ↓
.claude/CLAUDE.md 中：
  - [Jira Issue Reader](.claude/skills/jira-issue-reader/SKILL.md)
  - [Jira Wiki Reader](.claude/skills/jira-wiki-reader/SKILL.md)
  - [PR Creator](.claude/skills/pr-creator/SKILL.md)
    ↓
AI 知道这些 skills 可用，可在适当时机调用
```

**当前状态：** ✅ 完整配置

### 项目特定 Skills

```
目标：
  ai.project/.claude-plugin/settings.json：
    "enabledPlugins": {
      "mosavi-project-skills": true
    }
      ↓
  ai.project/.claude-plugin/marketplace.json
    注册项目特定 skills
      ↓
  ai.project/.claude/CLAUDE.md 中：
    [项目特定 Skills] 链接
      ↓
  AI 知道这些 skills 仅在本项目可用

当前状态：⏳ 待实现（marketplace.json 和 skills 定义）
```

---

## 新项目初始化清单

当将 `.claude/` 和 `ai.project/` 复制到新项目时，以下流程会自动执行：

### ✅ 自动生效

```
1. .claude/CLAUDE.md 被自动读取
2. 通用规范链接被发现
3. .claude/settings.json 被加载
4. 通用 plugins 被启用
5. 通用 skills 可用
```

### ⏳ 需要手动配置或扩展支持

```
1. ai.project/.claude/CLAUDE.md 的发现（取决于 AI 是否读过主 CLAUDE.md）
2. ai.project/.claude-plugin/settings.json 的加载（需要 Claude Code 支持）
3. 项目特定 plugins 的自动启用（需要 Claude Code 支持）
```

### 🔧 当前的临时解决方案

**直到 Claude Code 支持多 settings.json 之前，AI 可以：**

1. 通过 CLAUDE.md 中的链接发现项目特定规范
2. 根据需要手动加载相应规范（如 Go 编码标准）
3. 在工作流中识别需要哪些 standards 并主动加载

**示例：** 当用户要求"写 Go 代码"时，AI 自动读取 `ai.project/standards/01-go-coding-standard.md`，即使项目 plugins 没有正式启用。

---

## 故障排查

### 问题：通用规范没有被加载

**检查：**
1. `.claude/CLAUDE.md` 是否存在？✅
2. 规范链接是否正确？✅
3. 链接指向的文件是否存在？✅

**解决：** AI 会在任务开始时主动读取相应规范（见"自动触发规则"）。

### 问题：项目特定规范没有被发现

**检查：**
1. `ai.project/.claude/CLAUDE.md` 是否存在？✅
2. 主 CLAUDE.md 是否有指向它的链接？✅

**解决：** 如果 Claude Code 不自动读取项目特定 CLAUDE.md，AI 可以：
- 在用户要求时主动读取 `ai.project/.claude/CLAUDE.md`
- 在相关工作流中（如编码）自动读取对应的项目规范

### 问题：项目特定 plugins 没有启用

**原因：** Claude Code 当前不支持读取多个 settings.json（仅支持 `.claude/settings.json`）。

**临时解决：**
1. 所有项目 plugins 暂时在 `.claude/settings.json` 中启用（会污染通用配置）
2. 等待 Claude Code 扩展支持（预期未来版本）

**长期解决：** 一旦 Claude Code 支持，直接使用 `ai.project/.claude-plugin/settings.json`。

---

## 最佳实践

### ✅ 推荐做法

1. **所有通用规范都链接到 CLAUDE.md**
   - 确保任何项目都能发现通用规范

2. **项目特定规范链接到 ai.project/.claude/CLAUDE.md**
   - 单一入口，易于发现和维护

3. **使用相对路径**
   - `./.claude/CLAUDE.md` ← 当前目录
   - `../ai.project/.claude/CLAUDE.md` ← 兄弟目录

4. **定期检查链接有效性**
   - 当重构规范目录时，更新所有 CLAUDE.md 文件

### ❌ 避免做法

1. **不要硬编码绝对路径** ❌
   ```
   /Users/carlos/work/... ← 不可迁移
   ```

2. **不要在 settings.json 中列出项目特定的 plugins**
   ```json
   // ❌ 不好
   "enabledPlugins": {
     "mosavi-project-skills": true  ← 只在本项目有
   }
   ```

3. **不要在多个地方重复规范链接**
   ```
   // ❌ 避免散落的链接
   主 CLAUDE.md 中有一份
   ai.project 中又有一份

   // ✅ 应该这样
   主 CLAUDE.md 中有统一的导航
   ```

---

**最后更新：** 2026-03-16

