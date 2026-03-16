# 外部规范发现机制

本文档讨论 Claude Code 如何从外部位置（GitHub、共享服务器等）动态引导发现规范和 skills。

---

## 问题背景

当前 Claude Code 的配置是**本地的、静态的**：
- 规范存储在项目目录中
- Skills 存储在本地 `.claude-plugin/` 中
- CLAUDE.md 只能链接本地文件或外部 URL

**需求：** 多个项目共享一套通用规范（如 Mosavi 团队的所有项目）

---

## 方案对比

### 方案 1：GitHub 上的共享规范库 ⭐ 推荐

**架构：**
```
GitHub
  └─ mosavi-guidelines/
      ├── .claude/
      │   ├── guidelines/
      │   │   ├── 01-workflow.md
      │   │   ├── 04-coding-principles.md
      │   │   └── ...
      │   ├── skills/
      │   │   ├── jira-issue-reader/
      │   │   └── ...
      │   ├── CLAUDE.md
      │   └── settings.json
      └── ai.project-templates/
          ├── standards/
          ├── skills/
          └── README.md

每个项目的本地 .claude/
  └─ CLAUDE.md （包含 GitHub 规范库的链接）
```

**工作流：**
```
项目初始化
  ↓
.claude/CLAUDE.md 中链接到 GitHub 规范
  ↓
Claude Code 读取 CLAUDE.md
  ↓
发现 GitHub 链接
  ↓
通过 WebFetch 获取远程 CLAUDE.md
  ↓
动态加载规范
```

**实现方式 1a：直接链接原始文件**

```markdown
# CLAUDE.md

## 通用规范（共享）

- [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
- [编码原则](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/04-coding-principles.md)

## 项目特定规范

- [Go 编码标准](../ai.project/standards/01-go-coding-standard.md)
```

**优点：**
- ✅ 无需本地存储通用规范
- ✅ 更新规范时，所有项目自动获得最新版本
- ✅ 适合多项目团队共享
- ✅ Claude Code 已支持 WebFetch，无需扩展

**缺点：**
- ❌ 需要 GitHub 访问权限（公开仓库）
- ❌ 离线时无法加载
- ❌ 需要手工维护 GitHub 链接

**例子：**
```
原本：
[开发工作流](.claude/guidelines/01-workflow.md)

改为：
[开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
```

---

### 方案 1b：通过 extraKnownMarketplaces 从 GitHub 加载 Skills

Claude Code 支持通过 `extraKnownMarketplaces` 从 GitHub 加载 marketplace：

```json
// .claude/settings.json
{
  "extraKnownMarketplaces": {
    "mosavi-team-skills": {
      "source": "github",
      "repo": "mosavi-team/guidelines",
      "path": ".claude-plugin/marketplace.json",
      "ref": "main"
    }
  },
  "enabledPlugins": {
    "shared-jira-tools@mosavi-team-skills": true,
    "shared-git-tools@mosavi-team-skills": true
  }
}
```

**工作流：**
```
Claude Code 启动
  ↓
读取 settings.json
  ↓
发现 extraKnownMarketplaces
  ↓
从 GitHub clone mosavi-team/guidelines
  ↓
读取 .claude-plugin/marketplace.json
  ↓
注册 mosavi-team-skills marketplace
  ↓
启用指定的 plugins
```

**优点：**
- ✅ 官方支持的机制（Claude Code 内置）
- ✅ Marketplace 签名和验证
- ✅ 自动版本管理（git ref）
- ✅ 自动缓存和更新
- ✅ 可配置自动更新频率

**缺点：**
- ❌ 仓库必须是公开的（或使用 SSH keys）
- ❌ 第一次加载比较慢（clone 整个仓库）
- ❌ 需要 Git 和网络访问

**最佳实践：**
```json
{
  "extraKnownMarketplaces": {
    "mosavi-standards": {
      "source": "github",
      "repo": "mosavi-team/standards",
      "path": ".claude-plugin/marketplace.json",
      "ref": "main",
      "autoUpdate": true
    }
  }
}
```

---

### 方案 2：本地共享目录（团队内 NAS/服务器）

**架构：**
```
/shared/mosavi-standards/
  ├── .claude/
  │   ├── guidelines/
  │   ├── skills/
  │   └── CLAUDE.md
  └── ai.project-templates/

每个项目：
  .claude/CLAUDE.md → 链接到 /shared/mosavi-standards/
```

**工作流：**
```
.claude/CLAUDE.md 中链接本地路径
  ↓
[开发工作流](/shared/mosavi-standards/.claude/guidelines/01-workflow.md)
  ↓
Claude Code 读取本地文件
```

**优点：**
- ✅ 快速访问（本地网络）
- ✅ 离线可用（如果本地缓存）
- ✅ 无需公网访问

**缺点：**
- ❌ 需要团队成员都能访问共享位置
- ❌ 不适合分布式团队
- ❌ 对 Windows/Mac 路径支持差
- ❌ 无法版本控制

**实现方式：**

`settings.json` 中配置共享目录访问：
```json
{
  "permissions": {
    "additionalDirectories": [
      "/shared/mosavi-standards"
    ]
  }
}
```

或者 `settings.local.json`（适合本机特定路径）：
```json
{
  "permissions": {
    "additionalDirectories": [
      "/Volumes/SharedDrive/mosavi-standards"  // macOS
    ]
  }
}
```

---

### 方案 3：Git Submodule（本地仓库模式）

**架构：**
```
mosavi-firebaseFunction/
  ├── .claude/ → 本地
  ├── shared-standards/ → git submodule
  │   └── 来自 github.com/mosavi-team/standards
  └── ai.project/ → 本地
```

**初始化：**
```bash
git submodule add https://github.com/mosavi-team/standards.git shared-standards
```

**CLAUDE.md 中链接：**
```markdown
[开发工作流](../shared-standards/.claude/guidelines/01-workflow.md)
```

**优点：**
- ✅ 版本控制友好（子模块有特定 commit hash）
- ✅ 离线可用（已 clone 情况下）
- ✅ 跨平台兼容
- ✅ 可精确控制版本

**缺点：**
- ❌ 增加项目复杂性
- ❌ 团队成员需要理解 git submodule
- ❌ 每个项目都需要独立维护子模块
- ❌ 推送时需要同时更新主仓库和子模块

**最佳实践：**
```bash
# 初始化
git submodule add -b main \
  https://github.com/mosavi-team/standards.git \
  shared-standards

# 维护
git submodule update --remote  # 拉取最新
git add shared-standards       # 提交新版本
```

---

## 推荐方案组合

根据你的场景：

### 📌 场景 1：团队多项目，统一规范（推荐）

**使用方案 1b（extraKnownMarketplaces）+ 直接链接**

```json
// .claude/settings.json
{
  "extraKnownMarketplaces": {
    "mosavi-team": {
      "source": "github",
      "repo": "mosavi-team/guidelines",
      "path": ".claude-plugin/marketplace.json",
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "shared-jira-tools@mosavi-team": true,
    "shared-git-tools@mosavi-team": true
  }
}
```

```markdown
// .claude/CLAUDE.md
## 通用规范（来自 GitHub）

- [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
- [编码原则](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/04-coding-principles.md)

## 项目特定规范

- [Go 编码标准](../ai.project/standards/01-go-coding-standard.md)
```

**结果：**
- ✅ Skills 通过 marketplace 自动管理
- ✅ 规范通过 GitHub 直接链接
- ✅ 更新规范时，所有项目自动获得最新版本
- ✅ 本地 ai.project 仍保存项目特定规范

---

### 📌 场景 2：本地团队，快速迭代

**使用方案 2（本地共享目录）**

```json
// settings.local.json
{
  "permissions": {
    "additionalDirectories": [
      "/shared/mosavi-team/standards"
    ]
  }
}
```

**适用：** 同一办公室、同一网络、快速开发迭代

---

### 📌 场景 3：版本控制友好，分布式团队

**使用方案 3（Git Submodule）**

```bash
git submodule add https://github.com/mosavi-team/standards.git shared-standards
```

**适用：** 分布式团队、需要精确版本控制、规范变化不频繁

---

## 实施步骤（方案 1b + 直接链接）

### 第 1 步：创建规范库（GitHub）

```bash
mkdir mosavi-team/guidelines
cd mosavi-team/guidelines

# 创建 .claude-plugin 目录
mkdir -p .claude-plugin
cat > .claude-plugin/marketplace.json << 'EOF'
{
  "$schema": "https://claude.ai/schemas/marketplace.json",
  "version": "1.0",
  "plugins": [
    {
      "id": "shared-jira-tools",
      "marketplace": "mosavi-team",
      "name": "Shared Jira Tools",
      "description": "Team-wide Jira integration skills",
      "location": "skills/jira-tools/SKILL.md"
    }
  ]
}
EOF

# 创建其他文件
mkdir -p .claude/guidelines
# ... 添加 guidelines 文件
```

### 第 2 步：更新项目的 settings.json

```json
{
  "extraKnownMarketplaces": {
    "mosavi-team": {
      "source": "github",
      "repo": "mosavi-team/guidelines",
      "path": ".claude-plugin/marketplace.json",
      "ref": "main",
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "shared-jira-tools@mosavi-team": true
  }
}
```

### 第 3 步：更新 CLAUDE.md

```markdown
## 通用规范（团队共享，来自 GitHub）

- [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
- [编码原则](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/04-coding-principles.md)
- [分支管理](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/03-branch-management.md)
```

### 第 4 步：验证

```bash
# 重启 Claude Code
# 检查是否自动加载了 mosavi-team marketplace
# 检查是否可以调用 /shared-jira-tools
```

---

## 缺点和限制

| 方案 | 缺点 | 解决方案 |
|------|------|---------|
| GitHub 直接链接 | 需要公网访问 | 使用私有仓库 + SSH keys |
| GitHub 直接链接 | 首次加载较慢 | 使用 CDN 或缓存 |
| extraKnownMarketplaces | 第一次 clone 较慢 | 接受初始化成本，或使用浅 clone |
| 本地共享目录 | 不适合分布式 | 改用 GitHub |
| Git Submodule | 复杂度高 | 简化为直接链接 + GitHub |

---

## 最佳实践

### ✅ 推荐

1. **通用规范用 GitHub**
   ```markdown
   [工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
   ```

2. **项目特定规范用本地**
   ```markdown
   [Go 编码标准](../ai.project/standards/01-go-coding-standard.md)
   ```

3. **Skills 用 extraKnownMarketplaces**
   ```json
   "extraKnownMarketplaces": {
     "mosavi-team": {
       "source": "github",
       "repo": "mosavi-team/guidelines"
     }
   }
   ```

4. **使用 GitHub 的 main 分支或 release tag**
   ```
   main ← 最新开发版本
   v1.0 ← 稳定版本
   ```

### ❌ 避免

1. **不要用绝对本机路径链接外部规范**
   ```
   ❌ /Users/carlos/shared/mosavi-guidelines/...
   ```

2. **不要在 settings.json 中硬编码 GitHub 用户名**
   ```
   ❌ https://github.com/carlos/guidelines
   ✅ https://github.com/mosavi-team/guidelines
   ```

3. **不要让每个项目维护自己的规范副本**
   ```
   ❌ mosavi-firebaseFunction/.claude/guidelines
      mosavi-push-service/.claude/guidelines  ← 重复

   ✅ mosavi-team/guidelines/.claude/guidelines
      → 所有项目链接到这个
   ```

---

## 总结对比

```
┌──────────────────┬──────────┬──────────┬──────────┬─────────┐
│ 方案              │ 网络需求 │ 离线     │ 版本管理 │ 复杂性  │
├──────────────────┼──────────┼──────────┼──────────┼─────────┤
│ 1a: 直接链接     │ ✅ 需要   │ ❌      │ ✅ 好   │ 低     │
│ 1b: Marketplace  │ ✅ 需要   │ ❌      │ ✅ 好   │ 中     │
│ 2: 共享目录      │ ❌ 本地   │ ✅      │ ❌      │ 低     │
│ 3: Git Submodule │ ✅ 需要   │ ✅      │ ✅✅ 好 │ 高     │
└──────────────────┴──────────┴──────────┴──────────┴─────────┘
```

**我的推荐：** 方案 1（直接链接 + extraKnownMarketplaces）
- 足够简单
- GitHub 官方支持
- 适合分布式团队
- 易于维护和更新

---

**最后更新：** 2026-03-16

