# 开发工作流

## 完整流程

### 1. 接收需求
从 JIRA 读取票号内容，确认需求范围。

**如何读取 Jira 票号？**

参考 **Skill: [Jira API Access](../../.claude/skills/jira-api-access.md)** — 通用指导文档

项目特定配置（Jira 邮箱、Token、Domain）在 `.claude-local/config/` 中

**实现方式：**
- 自动调用：AI 识别到需要读取票号时，自动调用 `jira-api-access` Skill
- 手动调用：用户可输入 `/jira-api-access MOS-XXXX` 显式调用

**⚠️ 关键规则：票号读取失败处理**
- 如果 Jira API 返回 404 或权限错误，**立即停止流程**
- 向用户提示：`❌ 票号 MOS-XXXX 读取失败：[具体错误信息]`
- 不进行后续步骤（不创建设计文档、不创建分支、不编码）
- 等待用户反馈：确认票号有效或提供新的票号

### 2. 创建设计文档
在 `design/<JIRA工单号>.md` 记录背景、分析与修改方案。
**方案确认后再开始实现。**

详见 [设计文档编写指南](design-document.md)：
- 标准模板和编写要点
- 审查标准和检查清单
- 何时需要设计文档

### 3. 创建分支
```bash
git checkout stage && git pull MosaviJP stage
git checkout -b <变更类型>/MOS-XXXX-<描述>
```
分支命名规范参考 [branch.md](branch.md)。

### 4. 实现

编码规约参考 [coding.md](coding.md)。

### 5. 提交前审查

执行 commit 前，必须按照[提交前审查基准](pre-commit-review.md)完成全部检查项。
审查结果需提示给用户，获得用户确认后方可提交。

### 6. 提交
```bash
git add <具体文件>
git commit -m "<变更类型>(MOS-XXXX): <简述>

- 变更点1
- 变更点2"
```

### 7. 推送 & 创建 PR
```bash
git push MosaviJP <分支名>
```
PR 的 base 分支为 `stage`。
