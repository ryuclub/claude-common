#!/bin/bash
# claude-common 初始化脚本
# 用途：在 auto-load.sh 同步 claude-common 后调用
# 作用：初始化项目配置和 plugins

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
info() { echo "  $1"; }

echo ""
echo "=========================================="
echo " Claude Common 初始化"
echo "=========================================="
echo ""

# 获取缓存目录
CACHE_DIR="${1:-.claude/.remote-cache}"
PROJECT_SETTINGS=".claude/settings.json"

# 1. 确保 settings.json 存在且有 skills 字段
if [ -f "$PROJECT_SETTINGS" ]; then
  log "找到项目 settings.json"

  # 检查是否有 skills 字段，没有则添加
  if ! grep -q '"skills"' "$PROJECT_SETTINGS" 2>/dev/null; then
    info "添加通用 skills 路径到 settings.json..."
    python3 << 'PYTHON_EOF'
import json
from pathlib import Path

settings_file = Path("./.claude/settings.json")
if settings_file.exists():
    with open(settings_file) as f:
        config = json.load(f)

    if "skills" not in config:
        config["skills"] = [
            ".claude/skills",
            ".claude/.remote-cache/skills"
        ]

        with open(settings_file, "w") as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
            f.write("\n")
        print("✓ 已添加 skills 字段")
PYTHON_EOF
  else
    info "settings.json 已有 skills 配置"
  fi
else
  warn "项目 settings.json 不存在，请在 .claude 目录中创建"
fi

# 2. 运行 plugin-installer.sh 安装插件
echo ""
if [ -f "$CACHE_DIR/hooks/plugin-installer.sh" ]; then
  info "初始化插件..."
  bash "$CACHE_DIR/hooks/plugin-installer.sh"
else
  warn "未找到 plugin-installer.sh"
fi

echo ""
echo "=========================================="
log "Claude Common 初始化完成"
echo "=========================================="
echo ""
