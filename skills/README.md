# 通用 Skills

本目录包含**跨项目可复用**的 Skills。这些 Skills 实现了通用的工具和能力，可以在任何项目中使用。

---

## 📋 可用的 Skills

### 1. jira-issue-reader

**目标：** 读取和分析 Jira 工作项（Issue）

**调用方式：**
```bash
/jira-issue-reader MOS-2590
```

**特点：**
- 支持 Jira REST API v3
- 获取工作项详情、历史、评论
- 自动触发：当用户提到 MOS-XXXX 时

---

### 2. jira-wiki-reader

**目标：** 读取和解析 Confluence Wiki 文档

**调用方式：**
```bash
# 支持 Wiki URL
/jira-wiki-reader https://mosavi.atlassian.net/wiki/spaces/SCRUM/pages/16941207

# 支持页面标题
/jira-wiki-reader "MOS-2590 架构设计方案"

# 支持 Page ID
/jira-wiki-reader 16941207
```

**特点：**
- 支持 3 种输入格式（URL、标题、Page ID）
- 获取页面内容、版本历史
- 自动触发：当用户需要查询文档时

---

### 3. pr-creator

**目标：** 根据 Git diff 和 JIRA 信息自动生成 PR 描述和创建 PR

**调用方式：**
```bash
/pr-creator
```

**特点：**
- 基于项目 PR 模板生成描述
- 自动判定 PR 标签
- 支持 Draft 或正式 PR
- 自动触发：当用户提到创建 PR 时

---

## 🔗 项目特定 Skills

项目特定的 Skills 保存在 `.claude-local/skills/` 目录下。

详见 [.claude-local/skills/README.md](../../.claude-local/skills/README.md)

---

## 📦 跨项目复用

这些 Skills 可以直接复用到其他项目中：

1. **复制整个 `.claude/skills/` 目录** 到新项目
2. **在 `.claude-plugin/marketplace.json` 中注册** 指向该目录的路径
3. **更新 `.claude/settings.json`** 启用这些 skills

---

## 更新和维护

- **通用 Skills** 的改进会自动应用到所有使用该目录的项目
- **项目特定的改进** 应保存在 `.claude-local/skills/` 中，不影响其他项目

---

**最后更新：** 2026-03-16
