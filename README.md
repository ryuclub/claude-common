# claude-common

通用的 Claude Code 规范库和 Skills 工具库。

## 用途

为所有项目提供：
- **7 个通用开发规范**（guidelines/）
- **通用能力工具**（skills/）
- **项目配置模板**（settings.json）

## 使用方式

项目通过 hook 自动从本仓库同步规范和 Skills：

**在 `.claude/hooks/auto-load.sh` 中添加：**

```bash
# 同步 claude-common
git clone --depth=1 https://github.com/ryuclub/claude-common.git .claude/.remote-cache/

# 调用初始化脚本
if [ -f ".claude/.remote-cache/hooks/init.sh" ]; then
  bash .claude/.remote-cache/hooks/init.sh ".claude/.remote-cache"
fi
```

init.sh 会自动：
- 复制 settings.json（如果项目还没有）
- 检查和提示安装缺失的 plugins

## 内容

- [`guidelines/`](./guidelines/) — 7 个通用规范
- [`skills/`](./skills/) — 4 个通用 Skills
- [`CLAUDE.md`](./CLAUDE.md) — 规范库入口

## 提交规则

**提交到 Git：**
- 所有规范文件（guidelines/）
- 所有 Skills（skills/）
- CLAUDE.md、settings.json

**不提交到 Git：**
- 各项目的本地配置（它们在各项目的 `.claude/` 中）
- `.remote-cache/`（项目的缓存，由 hook 生成）

## 更新流程

1. 在本仓库修改规范文件
2. 提交并推送到 main 分支
3. 各项目会在 24h 内自动拉取最新版本
4. 或手动删除项目的 `.claude/.remote-cache/.sync` 强制立即更新

## 贡献

遵循项目规范提交：

```bash
git checkout -b feature/your-change
# 修改文件
git add .
git commit -m "规范: 说明改动"
git push origin feature/your-change
```

然后创建 Pull Request。
