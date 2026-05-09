#!/bin/bash
# plugin-setup.sh
# 自动注册 marketplace 并安装通用插件和 skills

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
info() { echo "  $1"; }

# 检查指定 plugin 是否已安装。
# `claude plugin list` 实际输出为 "  ❯ name@marketplace" 这种带前缀的格式，
# 早期使用 grep -q "^${plugin}" 因 ^ 锚定行首而永远不命中，导致：
#   - 卸载段：跳过卸载（静默失败）
#   - 安装段：每次都误判未装、走 install 命令（CLI 自身幂等才掩盖此 bug）
# 现匹配 "name 出现在某行末尾、且前面是空白" —— 兼容当前的箭头格式与未来可能的纯文本格式。
plugin_installed() {
  claude plugin list 2>/dev/null | grep -qE "(^|[[:space:]])${1}\$"
}

echo ""
echo "🔌 初始化插件和 Skills..."
echo ""

# 检查 claude 命令是否可用
if ! command -v claude &> /dev/null; then
  warn "Claude Code CLI 未安装或不在 PATH 中"
  warn "请确保已安装 Claude Code 并在终端中运行本脚本"
  exit 0
fi

# 1. 注册 marketplace
info "注册 marketplace..."
MARKETPLACES=(
  "https://github.com/anthropics/skills"
  "https://github.com/anthropics/claude-plugins-official"
  "https://github.com/ryuclub/claude-common"
)

for marketplace in "${MARKETPLACES[@]}"; do
  # 检查是否已注册
  if claude plugin marketplace list 2>/dev/null | grep -q "$marketplace"; then
    info "已注册: $marketplace"
  else
    if claude plugin marketplace add "$marketplace"; then
      log "注册成功: $marketplace"
    else
      warn "注册失败: $marketplace"
    fi
  fi
done

# 2. 安装官方插件
echo ""
info "安装官方插件..."
PLUGINS=(
  "github@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
)

for plugin in "${PLUGINS[@]}"; do
  # 检查是否已安装
  if plugin_installed "$plugin"; then
    info "已安装: $plugin"
  else
    if claude plugin install "$plugin"; then
      log "已安装: $plugin"
    else
      warn "安装失败: $plugin"
    fi
  fi
done

# 3. 卸载已废弃的 Anthropic Skills plugin
# 上游 anthropics/skills 仓库为 document-skills / example-skills / claude-api
# 三个 plugin 都声明了 source: "./"，每装一个都会 clone 整棵 repo（含全部 17 个
# skill 目录），导致同一份 skill 被注册 3 遍、磁盘占用 3 倍。
# 现统一只保留 document-skills；其安装目录依然包含全部 17 个 skill，功能不缺失。
echo ""
info "清理已废弃的 Anthropic Skills plugin..."
OBSOLETE_PLUGINS=(
  "example-skills@anthropic-agent-skills"
  "claude-api@anthropic-agent-skills"
)

for plugin in "${OBSOLETE_PLUGINS[@]}"; do
  if plugin_installed "$plugin"; then
    if claude plugin uninstall "$plugin"; then
      log "已卸载（去重）: $plugin"
    else
      warn "卸载失败: $plugin"
    fi
  fi
done

# 4. 安装 Anthropic Skills（仅保留 document-skills，已含全部 17 个 skill）
echo ""
info "安装 Anthropic Skills..."
ANTHROPIC_SKILLS=(
  "document-skills@anthropic-agent-skills"
)

for skill in "${ANTHROPIC_SKILLS[@]}"; do
  # 检查是否已安装
  if plugin_installed "$skill"; then
    info "已安装: $skill"
  else
    if claude plugin install "$skill"; then
      log "已安装: $skill"
    else
      warn "安装失败: $skill"
    fi
  fi
done

# 5. 安装通用库的 Skills
echo ""
info "安装通用库 Skills..."
COMMON_SKILLS=(
  "generic-jira-tools@claude-generic-skills"
  "generic-git-tools@claude-generic-skills"
)

for skill in "${COMMON_SKILLS[@]}"; do
  # 检查是否已安装
  if plugin_installed "$skill"; then
    info "已安装: $skill"
  else
    if claude plugin install "$skill"; then
      log "已安装: $skill"
    else
      warn "安装失败: $skill"
    fi
  fi
done

echo ""
log "插件和 Skills 初始化完成"
echo ""
