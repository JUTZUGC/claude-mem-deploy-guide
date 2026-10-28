# Claude-Mem 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://docs.claude-mem.ai/installation
# 更新日期：2026-10-28
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw '需要先安装 Node.js' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

node -e "const a=Number(process.versions.node.split('.')[0]); if (a < 20) { throw new Error('需要 Node.js 20 或更高版本') }"
npx.cmd -y claude-mem@latest install --provider host
npx.cmd -y claude-mem@latest doctor

Write-Host ''

Write-Host '安装完成：重启 Claude Code，新开会话即可；用 npx claude-mem doctor 检查状态'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://docs.claude-mem.ai/installation'
