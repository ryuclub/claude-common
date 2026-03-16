# 分支管理规则

## 基本规则

- 以 `stage` 分支为基点创建新分支
- 完成开发后，向 `stage` 分支提交 Pull Request

## 分支命名规范

格式：`<变更类型>/<JIRA工单号>-<描述>`

| 变更类型   | 用途               |
|------------|--------------------|
| `feat`     | 新功能开发         |
| `fix`      | Bug 修复           |
| `hotfix`   | 紧急 Bug 修复      |
| `perf`     | 性能优化           |
| `refactor` | 代码重构           |
| `chore`    | 构建/配置变更      |
| `docs`     | 文档变更           |

## 示例

```
feat/MOS-1234-add-user-auth
fix/MOS-2345-fix-login-bug
perf/MOS-2569-optimize-log-output
```
