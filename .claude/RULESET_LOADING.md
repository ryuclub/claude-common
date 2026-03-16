# 规范和流程的动态加载机制

本文档解决一个核心问题：**除了 Skills，其他规范（Guidelines、Standards、Workflows）如何实现动态加载？**

---

## 问题陈述

当前架构的局限：

```
✅ Skills 可以动态加载
   └─ 通过 extraKnownMarketplaces + marketplace.json

❌ 规范文件必须本地存储
   ├─ Guidelines（.claude/guidelines/*.md）
   ├─ Standards（ai.project/standards/*.md）
   └─ Workflows（无标准位置）
```

**理想状态：** 规范应该像 Skills 一样，支持外部引导发现。

**使用场景：**
1. Mosavi 团队修改了通用 Guidelines
2. 所有项目自动获得最新版本
3. 无需每个项目手工更新

---

## 三层规范体系回顾

### 第 1 层：通用规范（Universal Guidelines）
```
来源：.claude/guidelines/
包括：
  - 01-workflow.md（7 步工作流）
  - 02-design-document.md（设计规范）
  - 03-branch-management.md（Git 规范）
  - 04-coding-principles.md（编码原则）
  - 05-review-checklist.md（代码审查）

特点：跨项目复用，稳定不变
```

### 第 2 层：项目特定规范（Project Standards）
```
来源：ai.project/standards/
包括：
  - 01-go-coding-standard.md
  - 02-testing-framework.md
  - 03-project-workflow.md
  - 04-ci-cd-pipeline.md

特点：Mosavi 项目特定，相对稳定
```

### 第 3 层：配置和流程（Configuration & Workflows）
```
来源：ai.project/ 下的各种配置
包括：
  - CONFIG.env（环境变量）
  - JIRA_API_ACCESS.md（API 访问方式）
  - PROJECT_WORKFLOW.md（项目工作流细化）

特点：项目特定，变化频繁
```

---

## 当前的加载方式

### 现状：文件链接 + 主动发现

```
流程：
  .claude/CLAUDE.md（主导航）
    ↓
  包含规范的链接
    ↓
  相对路径链接
    [开发工作流](./.claude/guidelines/01-workflow.md)
    ↓
  Claude Code 读取本地文件
```

**问题：**
- 所有规范文件必须本地存储
- 更新规范需要所有项目手工同步
- 无法实现"一次更新，全部同步"

---

## 方案 1：CLAUDE.md 中使用外部 URL

### 实现方式

在 CLAUDE.md 中混合本地和外部链接：

```markdown
## 通用规范（来自 GitHub）

- [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
- [设计文档编写指南](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/02-design-document.md)
- [分支管理规则](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/03-branch-management.md)
- [编码原则](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/04-coding-principles.md)
- [代码审查清单](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/05-review-checklist.md)

## 项目特定规范（本地）

- [Go 编码标准](../ai.project/standards/01-go-coding-standard.md)
- [测试框架](../ai.project/standards/02-testing-framework.md)
- [CI/CD 管道](../ai.project/standards/04-ci-cd-pipeline.md)
```

### 加载流程

```
Claude Code 启动
  ↓
读取 .claude/CLAUDE.md
  ↓
发现链接（混合本地和远程）
  ↓
本地链接：直接读取文件
远程链接：通过 WebFetch 获取
  ↓
AI 加载所有规范
```

### 优点

- ✅ 通用规范自动同步（来自 GitHub）
- ✅ 项目特定规范仍本地控制
- ✅ Claude Code 原生支持（WebFetch 已内置）
- ✅ 简单直观

### 缺点

- ❌ CLAUDE.md 中需要长的 GitHub URL
- ❌ 首次加载需要网络请求
- ❌ 离线无法访问远程规范
- ❌ 如果 GitHub 宕机，规范不可用

### 实现方式的改进：使用简短别名

创建 `.claude/REMOTE.md` 作为 URL 映射：

```markdown
<!-- .claude/REMOTE.md -->

# 远程规范映射

定义通用规范的远程地址

## 基础 URL

```
BASE_URL=https://raw.githubusercontent.com/mosavi-team/guidelines/main
```

## 规范 URL 映射

- WORKFLOW: ${BASE_URL}/.claude/guidelines/01-workflow.md
- DESIGN_GUIDE: ${BASE_URL}/.claude/guidelines/02-design-document.md
- BRANCH_RULES: ${BASE_URL}/.claude/guidelines/03-branch-management.md
- CODING_PRINCIPLES: ${BASE_URL}/.claude/guidelines/04-coding-principles.md
- REVIEW_CHECKLIST: ${BASE_URL}/.claude/guidelines/05-review-checklist.md
```

然后在 CLAUDE.md 中使用别名（虽然 Markdown 不支持变量替换，但这可以作为文档约定）。

---

## 方案 2：Hooks 系统动态加载规范

### 理论基础

Claude Code 支持 `hooks`，可以在特定事件时执行命令。我们可以利用这个机制：

```json
// .claude/settings.json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "bash .claude/hooks/load-remote-guidelines.sh"
      }
    ]
  }
}
```

### 脚本实现

```bash
#!/bin/bash
# .claude/hooks/load-remote-guidelines.sh

REMOTE_BASE="https://raw.githubusercontent.com/mosavi-team/guidelines/main"
LOCAL_CACHE=".claude/.remote-cache"

mkdir -p "$LOCAL_CACHE"

# 下载通用规范
echo "Syncing remote guidelines..."

curl -s "$REMOTE_BASE/.claude/guidelines/01-workflow.md" \
  -o "$LOCAL_CACHE/01-workflow.md"

curl -s "$REMOTE_BASE/.claude/guidelines/02-design-document.md" \
  -o "$LOCAL_CACHE/02-design-document.md"

# ... 下载其他规范

echo "Remote guidelines updated: $(date)" > "$LOCAL_CACHE/.sync"
```

然后在 CLAUDE.md 中链接本地缓存：

```markdown
[开发工作流](./.claude/.remote-cache/01-workflow.md)
```

### 加载流程

```
Claude Code 启动
  ↓
触发 SessionStart hook
  ↓
执行 load-remote-guidelines.sh
  ↓
下载远程规范到本地缓存
  ↓
AI 读取 CLAUDE.md
  ↓
所有规范链接（包括缓存的远程规范）
  ↓
加载完整规范集
```

### 优点

- ✅ 自动同步（每次启动时）
- ✅ 离线仍可用（使用缓存）
- ✅ 可以检查版本（检查 .sync 文件）
- ✅ 灵活的更新策略（可配置何时更新）

### 缺点

- ❌ 首次启动较慢（需要下载）
- ❌ 需要编写和维护 hook 脚本
- ❌ 缓存目录会增加项目大小
- ❌ 依赖网络连接（首次）

### 改进：只在必要时更新

```bash
#!/bin/bash
# .claude/hooks/load-remote-guidelines.sh (改进版)

REMOTE_BASE="https://raw.githubusercontent.com/mosavi-team/guidelines/main"
LOCAL_CACHE=".claude/.remote-cache"
SYNC_FILE="$LOCAL_CACHE/.sync"
CACHE_TTL=$((24 * 3600))  # 24 小时

mkdir -p "$LOCAL_CACHE"

# 检查缓存是否过期
if [ -f "$SYNC_FILE" ]; then
  LAST_SYNC=$(stat -f%m "$SYNC_FILE" 2>/dev/null || stat -c%Y "$SYNC_FILE")
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - LAST_SYNC))

  if [ $ELAPSED -lt $CACHE_TTL ]; then
    echo "Cache still valid (updated $(($ELAPSED / 3600)) hours ago)"
    exit 0
  fi
fi

echo "Updating remote guidelines..."

# 下载并更新
curl -s "$REMOTE_BASE/.claude/guidelines/01-workflow.md" \
  -o "$LOCAL_CACHE/01-workflow.md"

# ... 下载其他规范

echo "$(date +%s)" > "$SYNC_FILE"
echo "Remote guidelines updated"
```

---

## 方案 3：多层 CLAUDE.md 结构

### 概念

创建一个分层的规范导航系统：

```
.claude/CLAUDE.md （主入口，指向各层规范）
  ├─ 引入 .claude/guidelines/INDEX.md （本地通用规范索引）
  ├─ 引入远程规范链接或 REMOTE.md （外部规范映射）
  └─ 引入 ../ai.project/.claude/CLAUDE.md （项目特定规范入口）

.claude/guidelines/INDEX.md （通用规范索引）
  ├─ [01-workflow.md](./01-workflow.md)
  ├─ [02-design-document.md](./02-design-document.md)
  └─ ...

.claude/REMOTE.md （远程规范映射，可选）
  └─ 说明如何从 GitHub 获取最新规范

../ai.project/.claude/CLAUDE.md （项目特定规范入口）
  ├─ 引入 ../standards/INDEX.md
  └─ 引入项目配置链接
```

### 主 CLAUDE.md 简化

```markdown
# AI 指南

## 通用规范

请参考 [通用规范索引](./.claude/guidelines/INDEX.md)

（或从外部加载）参考 [REMOTE.md](./.claude/REMOTE.md)

## 项目特定规范

请参考 [项目特定规范入口](../ai.project/.claude/CLAUDE.md)
```

### 优点

- ✅ 结构清晰，分层明确
- ✅ 易于维护和扩展
- ✅ 支持本地和远程混合
- ✅ 可逐步迁移到远程规范

### 缺点

- ❌ 多层链接较复杂
- ❌ 需要维护多个 INDEX.md
- ❌ 首次访问时需要多次跳转

---

## 方案 4：集中式规范服务（Web Server）

### 架构

建立一个中央规范服务：

```
规范服务（Mosavi Team 内部）
  ├─ /api/guidelines/{version}/{file}
  ├─ /api/standards/{project}/{version}/{file}
  └─ /api/workflows/{workflow-id}/{version}

每个项目的 CLAUDE.md
  └─ 链接到规范服务 API
```

### 例子

```markdown
[开发工作流](https://standards.mosavi.internal/api/guidelines/latest/01-workflow.md)
[Go 编码标准](https://standards.mosavi.internal/api/standards/mosavi/latest/01-go-coding-standard.md)
```

### 加载流程

```
Claude Code 启动
  ↓
读取 CLAUDE.md
  ↓
发现规范服务 URL
  ↓
请求规范服务 API
  ↓
服务返回最新规范内容
  ↓
AI 加载规范
```

### 优点

- ✅ 完全中央管理
- ✅ 可实现版本管理（latest/v1.0/v2.0 等）
- ✅ 可跟踪规范使用情况
- ✅ 可实现 A/B 测试（不同项目不同版本）
- ✅ 灵活的访问控制

### 缺点

- ❌ 需要维护规范服务
- ❌ 额外的基础设施成本
- ❌ 团队必须有访问服务的权限
- ❌ 服务宕机会导致规范不可用
- ❌ 过度工程（对大多数团队来说）

---

## 方案 5：AI 自主加载（当前实现）

### 工作方式

AI 在对话开始时：
1. 读取 CLAUDE.md
2. 根据任务类型自主判断需要哪些规范
3. 主动读取相应规范文件

```
用户开始任务
  ↓
AI 读取 CLAUDE.md
  ↓
AI 判断："这是编码任务，需要 Go 编码标准"
  ↓
AI 主动读取 ai.project/standards/01-go-coding-standard.md
  ↓
加载规范到 context
```

### 优点

- ✅ 简单（无需外部基础设施）
- ✅ 灵活（AI 可根据需要加载）
- ✅ 离线可用（所有文件本地存储）
- ✅ 易于测试和验证

### 缺点

- ❌ 规范必须本地存储（无法自动同步）
- ❌ 不同项目可能有不同版本
- ❌ 依赖 AI 判断（可能加载错误的规范）
- ❌ 无法实现"全团队规范同步"

---

## 方案对比

```
┌────────────┬────────┬──────────┬────────────┬──────────┬──────────┐
│ 方案       │ 复杂性 │ 网络依赖 │ 离线可用   │ 自动同步 │ 推荐度   │
├────────────┼────────┼──────────┼────────────┼──────────┼──────────┤
│ 1: URL     │ 低     │ ✅ 需要  │ ❌        │ ✅      │ ⭐⭐⭐  │
│ 2: Hooks   │ 中     │ ✅ 需要  │ ✅ 缓存   │ ✅      │ ⭐⭐⭐  │
│ 3: 多层    │ 中     │ 混合     │ 混合      │ 混合    │ ⭐⭐    │
│ 4: 服务    │ 高     │ ✅ 需要  │ ❌       │ ✅      │ ⭐      │
│ 5: 自主    │ 低     │ ❌      │ ✅       │ ❌      │ ⭐⭐    │
└────────────┴────────┴──────────┴────────────┴──────────┴──────────┘
```

---

## 推荐方案组合

### 🥇 第一选择：方案 1（URL） + 方案 2（Hooks）

**组合使用：**

```
第 1 层：通用规范
  ↓
方案 1（直接 GitHub URL）
  ├─ 简单直接
  ├─ 无需缓存
  └─ 首次加载获得最新版本

第 2 层：项目特定规范
  ↓
本地存储（当前做法）
  ├─ 项目特定
  └─ 变化频繁

第 3 层：自动同步
  ↓
方案 2（Hooks）
  ├─ 后台缓存通用规范
  ├─ 离线仍可用
  └─ 定时更新检查
```

**实现步骤：**

1. **GitHub 上创建规范库**
   ```
   mosavi-team/guidelines
   ├── .claude/guidelines/*.md
   └── .claude-plugin/marketplace.json
   ```

2. **每个项目的 settings.json**
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

3. **每个项目的 CLAUDE.md**
   ```markdown
   ## 通用规范

   - [开发工作流](./.claude/.remote-cache/01-workflow.md)
     或 [远程版本](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
   ```

4. **sync-guidelines.sh 脚本**
   ```bash
   #!/bin/bash
   REMOTE="https://raw.githubusercontent.com/mosavi-team/guidelines/main"
   CACHE=".claude/.remote-cache"

   mkdir -p "$CACHE"
   curl -s "$REMOTE/.claude/guidelines/01-workflow.md" -o "$CACHE/01-workflow.md"
   # ... 同步其他规范
   ```

### 🥈 第二选择：方案 1（URL）纯网络版

如果团队网络连接稳定，可以不用缓存：

```markdown
## 通用规范（来自 GitHub）

- [开发工作流](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/01-workflow.md)
- [设计文档](https://raw.githubusercontent.com/mosavi-team/guidelines/main/.claude/guidelines/02-design-document.md)
```

**优点：** 最简单，无需额外脚本或维护

**缺点：** 离线无法访问，需要网络连接

### 🥉 第三选择：方案 5（自主加载）保持现状

如果暂时无法建立外部规范库，继续使用当前方式：

```
优点：
  - 无需改变基础设施
  - AI 自主判断需要哪些规范
  - 完全离线可用

缺点：
  - 规范需要手工同步到各项目
  - 无法保证一致性
```

---

## 实施路线图

### Phase 1：准备（当前）

```
✅ 在 GitHub 创建 mosavi-team/guidelines
   ├─ 迁移 .claude/guidelines 文件
   └─ 迁移通用 skills

✅ 在当前项目中
   ├─ 保留本地 ai.project/ （项目特定）
   ├─ 删除或淡化本地 .claude/guidelines （使用远程）
   └─ 添加 hooks 脚本（可选）
```

### Phase 2：过渡（1-2 周）

```
使用方案 1（URL）
  ├─ 所有项目的 CLAUDE.md 链接到 GitHub
  ├─ 验证链接有效性
  └─ 测试 AI 加载规范

逐步淘汰本地副本
  └─ .claude/guidelines 可以删除（改用远程）
```

### Phase 3：优化（2-4 周）

```
添加 Hooks 脚本（方案 2）
  ├─ 实现 sync-guidelines.sh
  ├─ 配置 SessionStart hook
  └─ 缓存远程规范

支持离线工作
  └─ 首次启动时自动缓存
```

### Phase 4：维护

```
持续监控
  ├─ 检查 GitHub 链接有效性
  ├─ 定期更新规范库
  └─ 收集团队反馈

可选：升级到方案 4（规范服务）
  └─ 如果团队规模继续增长
```

---

## 总结

| 方面 | 当前状态 | 改进方向 |
|------|---------|---------|
| **Skills 加载** | ✅ 已支持动态加载 | extraKnownMarketplaces |
| **规范加载** | ❌ 静态，本地存储 | 方案 1（URL）或方案 2（Hooks） |
| **项目特定配置** | ✅ 本地存储 | 保持不变 |
| **整体架构** | 半静态 | 动态发现 + 本地缓存 |

**立即可做：**
1. GitHub 上创建 `mosavi-team/guidelines` 仓库
2. 迁移 `.claude/guidelines` 到那里
3. 更新项目的 CLAUDE.md，使用 GitHub URL
4. 删除或归档本地 `.claude/guidelines`

**后续可做：**
1. 添加 hooks 脚本实现缓存
2. 支持规范版本管理（main/v1.0/v2.0）
3. 建立规范更新流程和通知机制

---

**最后更新：** 2026-03-16

