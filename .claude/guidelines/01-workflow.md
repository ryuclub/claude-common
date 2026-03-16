# 开发工作流

## 完整流程

### 1. 接收需求
从 JIRA 读取票号内容，确认需求范围。

**如何读取 Jira 票号？**

参考 **Skill: [Jira API Access](../../.claude/skills/jira-api-access.md)** — 通用指导文档

项目特定配置（Jira 邮箱、Token、Domain）在 `.claude-local/config/` 中

**实现方式：**
- 自动调用：AI 识别到需要读取票号时，自动调用 `jira-api-access` Skill
- 手动调用：用户可输入 `/jira-api-access <PROJECT-KEY>-XXXX` 显式调用

**⚠️ 关键规则：票号读取失败处理**
- 如果 Jira API 返回 404 或权限错误，**立即停止流程**
- 向用户提示：`❌ 票号 <PROJECT-KEY>-XXXX 读取失败：[具体错误信息]`
- 不进行后续步骤（不创建设计文档、不创建分支、不编码）
- 等待用户反馈：确认票号有效或提供新的票号

### 2. 创建设计文档
在 `design/changes/<JIRA工单号>.md` 记录背景、分析与修改方案。
**方案确认后再开始实现。**

详见 [设计文档编写指南](02-design-document.md)：
- 标准模板和编写要点
- 审查标准和检查清单
- 何时需要设计文档

**设计审查：** 方案需获得 2+ 同意后方可进行实现

### 3. 创建分支
```bash
git checkout <base-branch> && git pull origin <base-branch>
git checkout -b <change-type>/<PROJECT-KEY>-XXXX-<description>
```

分支命名规范参考 [分支管理](03-branch-management.md)。

**base-branch 选择指导：**
- 通常：`main` 或 `master`（生产稳定分支）
- 可选：`develop`（开发分支）、`stage`（预发布分支）
- 项目约定：参考 `03-branch-management.md`

### 4. 实现代码

编码规约参考 [编码原则](04-coding-principles.md) 和项目的编码标准。

遵循：
- 代码注释和文档使用中文
- 错误处理必须显式处理，禁止忽略错误
- 保持代码清晰可维护

### 5. 提交前审查

执行 commit 前，必须按照 [提交前审查清单](06-pre-commit-review.md) 完成全部检查项。

**关键检查项：**

- [ ] 分支名符合规范
- [ ] 变更内容与设计文档一致
- [ ] 不包含机密信息、调试代码
- [ ] 变更影响范围已评估
- [ ] 测试已通过（单元/集成）
- [ ] 文档已更新
- [ ] 获得用户确认

审查结果需提示给用户，获得用户确认后方可提交。

### 6. 提交（commit）

```bash
git add <具体文件>
git commit -m "<change-type>(<PROJECT-KEY>-XXXX): <简述>

- 变更点1
- 变更点2"
```

**commit message 规范：**
- 格式：`<change-type>(<ticket>): <summary>`
- change-type: feat/fix/refactor/perf/docs/chore 等
- ticket: 对应的 JIRA 工单号
- summary: 简洁的变更描述（<50 字）

### 7. 推送 & 创建 PR

```bash
git push origin <branch-name>
```

创建 PR 到 `<base-branch>`，描述中包括：
- 变更目的
- 主要改动列表
- 影响范围
- 测试确认项

**PR 审查：** 需要 2+ 批准后方可 merge

### 8. 处理代码审查意见

PR 创建后，收到代码审查评论时：

1. **评估每条意见** — 确认是否需要修正
2. **修正问题** — 如需修改，修正代码并推送新 commit
3. **逐一回复** — 对每条意见回复（说明修正内容或不修正的理由）
4. **重新审查** — 等待批准者再次审查

### 9. 事后整理

每次完成开发后（包含 PR 指摘对应），检查以下内容：

**规范更新：** 本次遇到的规则、注意点，是否需要补充到规范中？
- 新的编码模式 → 更新编码规范
- 新的工作流步骤 → 更新工作流文档
- 新的检查项 → 更新审查清单

**Skill 新增：** 本次操作中是否出现了可复用的步骤？
- 新的自动化流程 → 考虑封装为新的 Skill
- 新的脚本/工具 → 提取为可复用的 Skill

**目的：** 持续改进工作流和工具，让后续开发更高效
