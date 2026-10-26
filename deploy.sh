#!/usr/bin/env bash
set -euo pipefail
# Claude-Mem 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://docs.claude-mem.ai/installation
# 更新日期：2026-10-26
# 类型：script
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "需要先安装 Node.js"; exit 1; }

mkdir -p .download
cd .download

node -e "const a=Number(process.versions.node.split('.')[0]); if (a < 20) { console.error('需要 Node.js 20 或更高版本'); process.exit(1) }"
npx -y claude-mem@latest install --provider host
npx -y claude-mem@latest doctor

echo ""

echo "安装完成：重启 Claude Code，新开会话即可；用 npx claude-mem doctor 检查状态"
echo "若结果异常或需要改配置，请参考官方文档：https://docs.claude-mem.ai/installation"
