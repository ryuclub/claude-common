# 加载策略速查表

快速对比 Skills、规范和流程的加载方式。

---

## 三类可加载内容

### 1️⃣ Skills（技能工具）

**定义：** 可执行的操作，如 `/jira-issue-reader`、`/pr-creator`

**当前状态：** ✅ 支持动态加载

| 方案 | 加载方式 | 配置文件 | 适用场景 |
|------|---------|---------|---------|
| **本地** | 直接执行 | `.claude/skills/` | 项目特定 skills |
| **GitHub** | 通过 marketplace | `extraKnownMarketplaces` | 团队通用 skills |

**推荐配置：**
```json
{
  "extraKnownMarketplaces": {
    "mosavi-team": {
      "source": "github",
      "repo": "mosavi-team/guidelines",
      "path": ".claude-plugin/marketplace.json"
    }
  },
  "enabledPlugins": {
    "shared-jira-tools@mosavi-team": true
  }
}
```

---

### 2️⃣ 规范文件（Guidelines & Standards）

**定义：** 指导和标准文档，如 `01-workflow.md`、`01-go-coding-standard.md`

**当前状态：** ⏳ 部分支持（需要改进）

| 方案 | 加载方式 | 存储位置 | 优点 | 缺点 |
|------|---------|---------|------|------|
| **本地存储** | AI 主动读取 | 项目内 | 离线可用、简单 | 无法自动同步 |
| **GitHub URL** | WebFetch | GitHub | 实时同步 | 需要网络 |
| **本地缓存 + Hook** | 脚本 + 缓存 | `.remote-cache/` | 自动同步 + 离线 | 需要 hook 脚本 |

**推荐配置：**

最简单（GitHub URL 直接链接）：
```markdown
<!-- CLAUDE.md -->
[开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
```

最强大（Hooks 缓存）：
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "bash .claude/hooks/sync-guidelines.sh"
    }]
  }
}
```

---

### 3️⃣ 工作流和流程（Workflows & Processes）

**定义：** 如何执行某项工作的步骤和流程，如 Git 工作流、部署流程

**当前状态：** ⏳ 隐含在规范中（无显式支持）

| 方案 | 实现方式 | 载体 | 特点 |
|------|---------|------|------|
| **文档形式** | `.md` 文件 | 规范文件 | 人工阅读 |
| **脚本形式** | `.sh` / `.py` | Hook 脚本 | 自动执行 |
| **混合形式** | 文档 + 脚本 | 规范 + Hook | 文档指导 + 脚本自动化 |

**推荐：**
```
规范定义"应该做什么" → 文档形式（CLAUDE.md）
流程实现"如何做"    → Hook 脚本形式
```

---

## 当前架构现状

```
┌─────────────────────────────────────────────────┐
│ 应用启动（Claude Code）                          │
└──────────────────┬──────────────────────────────┘
                   ↓
        ┌──────────────────────┐
        │ 读取 .claude/        │
        │ settings.json        │
        └──────────────────────┘
                   ↓
        ┌──────────────────────┐
        │ ✅ 加载通用 Plugins  │
        │ （anthropic-tools）  │
        └──────────────────────┘
                   ↓
        ┌──────────────────────┐
        │ 读取 .claude/        │
        │ CLAUDE.md            │
        └──────────────────────┘
                   ↓
     ┌──────────────┬──────────────┐
     ↓              ↓
┌────────────┐ ┌──────────────────────┐
│ 通用规范   │ │ 项目特定规范入口     │
│（本地）    │ │ ai.project/.claude/  │
│❌ 无法    │ │ CLAUDE.md            │
│自动同步   │ │ ✅ 本地控制          │
└────────────┘ └──────────────────────┘
```

---

## 三种改进方向

### 方向 A：最简单（推荐短期）

**使用 GitHub URL 直接链接规范**

```markdown
<!-- .claude/CLAUDE.md -->
[开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
```

✅ 优点：
- 无需改变架构
- Claude Code 原生支持（WebFetch）
- 实现最快（今天就能做）

❌ 缺点：
- 需要网络连接
- 首次加载较慢
- 无离线支持

---

### 方向 B：平衡型（推荐中期）

**使用 Hooks 脚本缓存 + GitHub URL**

```bash
#!/bin/bash
# .claude/hooks/sync-guidelines.sh
REMOTE="https://raw.githubusercontent.com/mosavi-team/guidelines/main"
CACHE=".claude/.remote-cache"

mkdir -p "$CACHE"
curl -s "$REMOTE/.claude/guidelines/01-workflow.md" -o "$CACHE/01-workflow.md"
# ... 缓存其他规范
```

```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "bash .claude/hooks/sync-guidelines.sh"
    }]
  }
}
```

✅ 优点：
- 自动同步（每次启动）
- 离线可用（使用缓存）
- 灵活的更新策略

❌ 缺点：
- 需要编写 hook 脚本
- 缓存增加项目大小
- 首次启动较慢

---

### 方向 C：企业级（推荐长期）

**建立中央规范服务**

```
内部规范 API 服务
  ├─ /api/guidelines/latest/01-workflow.md
  ├─ /api/standards/mosavi/01-go-coding-standard.md
  └─ 版本管理、访问控制、使用统计
```

✅ 优点：
- 完全中央管理
- 支持版本、A/B 测试
- 可跟踪使用情况

❌ 缺点：
- 需要维护服务
- 额外基础设施
- 过度工程（当前阶段）

---

## 立即可执行的方案

### 🟢 方案：GitHub 规范库 + 方向 A

**准备工作（1 天）**
```bash
# 1. GitHub 上创建规范库
git clone https://github.com/mosavi-team/guidelines

# 2. 迁移规范文件
cp Mosavi-firebaseFunction/.claude/guidelines/* guidelines/.claude/guidelines/
cp Mosavi-firebaseFunction/.claude-plugin/marketplace.json guidelines/.claude-plugin/

# 3. 提交和推送
git add .
git commit -m "Initial: migrate guidelines and skills"
git push origin main
```

**项目集成（1 天）**

1. 删除本地 `.claude/guidelines/`（因为用远程的）
2. 更新 `.claude/CLAUDE.md`：
   ```markdown
   [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
   ```
3. 更新 `.claude/settings.json`：
   ```json
   {
     "extraKnownMarketplaces": {
       "mosavi-team": {
         "source": "github",
         "repo": "mosavi-team/guidelines",
         "path": ".claude-plugin/marketplace.json"
       }
     }
   }
   ```

**验证（0.5 天）**
- 重启 Claude Code
- 确认 GitHub 规范可访问
- 测试 `/shared-jira-tools` skills

---

## 对不同角色的影响

### 👨‍💻 开发者

| 当前 | 改进后 |
|------|--------|
| 规范存放在项目内，多个项目有副本 | 规范统一在 GitHub，所有项目同步 |
| 规范更新需要手工同步 | 规范更新自动获取（下次启动） |
| 离线时所有规范都可用 | 需要网络（但可使用缓存方案 B） |

### 👨‍🔧 架构师

| 当前 | 改进后 |
|------|--------|
| 维护多份规范副本的一致性难 | 单一源点（GitHub），易维护 |
| 无法跟踪规范版本 | 可通过 Git tag 管理版本 |
| 无法统计规范使用情况 | 可逐步升级到方案 C（服务） |

### 👔 团队负责人

| 当前 | 改进后 |
|------|--------|
| 规范更新需要通知所有项目 | 规范更新自动同步 |
| 无法确保所有项目使用最新规范 | 可配置强制版本或自动更新 |
| 无法发现规范使用情况 | 可通过服务（方案 C）统计 |

---

## 决策树

```
你需要动态加载什么？
│
├─ Skills（可执行的工具）
│  └─ 使用 extraKnownMarketplaces → GitHub marketplace
│     ✅ 官方支持，已实现
│
├─ 规范文件（指导和标准）
│  ├─ 需要离线支持？
│  │  ├─ 不需要 → 方向 A（URL）
│  │  └─ 需要 → 方向 B（Hook 缓存）
│  │
│  └─ 需要企业级管理？
│     ├─ 不需要 → 方向 A 或 B
│     └─ 需要 → 方向 C（服务）
│
└─ 工作流/流程
   └─ 使用 Hook 脚本自动化
      ├─ 预提交检查 → PreToolUse
      ├─ 启动时初始化 → SessionStart
      └─ 自定义触发 → 根据需要
```

---

## 推荐行动计划

### Week 1：建立 GitHub 规范库
- [ ] 创建 `mosavi-team/guidelines` 仓库
- [ ] 迁移 `.claude/guidelines/` 文件
- [ ] 迁移通用 skills 和 marketplace.json
- [ ] 更新 README 文档

### Week 2：集成到项目
- [ ] 更新 `.claude/settings.json` - extraKnownMarketplaces
- [ ] 更新 `.claude/CLAUDE.md` - GitHub URL 链接
- [ ] 删除本地 `.claude/guidelines/`
- [ ] 在 3-4 个项目中测试

### Week 3-4：验证和优化
- [ ] 收集团队反馈
- [ ] 优化 GitHub URL（如使用 CDN）
- [ ] （可选）添加 Hook 脚本实现缓存（方向 B）
- [ ] （可选）建立规范版本管理策略

### 长期：企业级升级（可选）
- [ ] 建立中央规范服务（方向 C）
- [ ] 集成规范版本管理
- [ ] 添加使用统计和监控

---

**最后更新：** 2026-03-16

