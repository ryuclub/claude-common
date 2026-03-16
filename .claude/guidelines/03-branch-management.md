# 分支管理规则

## 基本规则

- 以 `<base-branch>` 为基点创建新分支（通常为 `main`、`develop` 或 `stage`）
- 完成开发后，向 `<base-branch>` 分支提交 Pull Request
- 定期删除已合并的远程分支，保持分支列表整洁

## Base 分支选择

| Base 分支 | 用途 | 说明 |
|----------|------|------|
| `main` / `master` | 生产稳定分支 | 包含已发布的稳定版本，仅接受 Release 和 Hotfix 分支 |
| `develop` | 开发分支 | 开发中的功能汇总分支，作为新功能的基点 |
| `stage` / `pre` | 预发布分支 | 预发布环境，用于灰度测试 |

**默认选择：** 如无特殊说明，使用 `main` 作为 base 分支

## 分支命名规范

**格式：** `<change-type>/<PROJECT-KEY>-XXXX-<description>`

| 变更类型 | 用途 | 说明 |
|---------|------|------|
| `feat` | 新功能开发 | 对应 Issue/Feature 票 |
| `fix` | Bug 修复 | 对应 Bug 票 |
| `hotfix` | 紧急 Bug 修复 | 直接从 `main` 创建，修复后合并回 `main` 和 `develop` |
| `perf` | 性能优化 | 对应性能相关票 |
| `refactor` | 代码重构 | 对应重构票 |
| `chore` | 构建/配置变更 | 不影响功能的维护性改动 |
| `docs` | 文档变更 | 仅文档变更，无代码改动 |
| `release` | 版本发布 | 从 `develop` 创建，合并到 `main` 并打 tag |

**命名规则：**

- 变更类型必须小写
- 项目 Key 大写（如 `MOS`、`ABC`）
- 描述使用连字符分隔，小写单词
- 长度控制在 50 个字符以内

## 分支生命周期

```
main (生产)
  ↑
  └─ release/v1.2.0     (版本发布)

  └─ hotfix/MOS-123     (紧急修复，直接从 main 创建)

develop (开发汇总)
  ↑
  ├─ feat/MOS-234-auth  (新功能)
  ├─ fix/MOS-456-bug    (bug修复)
  ├─ perf/MOS-789-cache (性能优化)
  └─ refactor/MOS-999   (代码重构)
```

## 示例

**通用示例：**

```bash
feat/MOS-1234-add-user-auth
fix/MOS-2345-fix-login-bug
perf/MOS-2569-optimize-log-output
hotfix/MOS-999-critical-error
refactor/ABC-100-simplify-service
docs/PROJ-50-update-readme
chore/PROJ-60-update-deps
release/v2.0.0
```

## 分支删除

**合并后删除远程分支：**

```bash
git push origin --delete <branch-name>
```

**删除本地已合并分支：**

```bash
git branch -d <branch-name>
```

**定期清理：** 建议每周清理一次，保持分支列表不超过 10 个活跃分支
