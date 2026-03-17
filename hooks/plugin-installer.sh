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
  if timeout 30 claude plugin marketplace add "$marketplace" 2>/dev/null; then
    log "注册成功: $marketplace"
  else
    warn "注册失败或已注册: $marketplace"
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
  if timeout 30 claude plugin install "$plugin" 2>/dev/null; then
    log "已安装: $plugin"
  else
    warn "安装失败或已安装: $plugin"
  fi
done

# 3. 安装 Anthropic Skills
echo ""
info "安装 Anthropic Skills..."
ANTHROPIC_SKILLS=(
  "document-skills@anthropic-agent-skills"
  "example-skills@anthropic-agent-skills"
  "claude-api@anthropic-agent-skills"
)

for skill in "${ANTHROPIC_SKILLS[@]}"; do
  if timeout 30 claude plugin install "$skill" 2>/dev/null; then
    log "已安装: $skill"
  else
    warn "安装失败或已安装: $skill"
  fi
done

# 4. 安装通用库的 Skills
echo ""
info "安装通用库 Skills..."
COMMON_SKILLS=(
  "generic-jira-tools@claude-generic-skills"
  "generic-git-tools@claude-generic-skills"
)

for skill in "${COMMON_SKILLS[@]}"; do
  if timeout 30 claude plugin install "$skill" 2>/dev/null; then
    log "已安装: $skill"
  else
    warn "安装失败或已安装: $skill"
  fi
done

echo ""
log "插件和 Skills 初始化完成"
echo ""
