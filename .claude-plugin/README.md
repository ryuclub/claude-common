# 通用 Skills 插件管理

本目录管理**通用 Skills**（跨项目可复用）的安装和配置。

---

## 📦 marketplace.json

**作用：** 定义和注册所有通用 Skills

**特点：**
- ✅ 完全独立，不依赖项目特定配置
- ✅ 可直接复制到其他项目
- ✅ 所有引用都使用相对路径（相对于 `.claude/`）

**包含的 plugins：**

1. **generic-jira-tools**
   - jira-issue-reader
   - jira-wiki-reader

2. **generic-git-tools**
   - pr-creator

---

## 🔄 在其他项目中复用

**步骤：**

1. 复制整个 `.claude/` 目录到新项目
2. 在新项目的 `.claude/settings.json` 中启用：
   ```json
   {
     "enabledPlugins": {
       "generic-jira-tools@claude-generic-skills": true,
       "generic-git-tools@claude-generic-skills": true
     }
   }
   ```
3. 完成！所有通用 skills 即可使用

---

## 📝 修改通用 Skills

如果要改进通用 skills（如增强 jira-issue-reader），直接在 `../**/SKILL.md` 中修改。

该改进会自动应用到所有使用该 `.claude/` 副本的项目。

---

**最后更新：** 2026-03-16
