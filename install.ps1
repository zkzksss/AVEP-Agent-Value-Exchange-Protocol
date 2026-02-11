# AVEP 一键安装脚本 (Windows PowerShell)
# 使用方法: irm https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.ps1 | iex

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  AVEP 安装程序" -ForegroundColor Cyan
Write-Host "  AI Via Ethereum Paymaster" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Node.js
Write-Host "检查 Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js 已安装: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ 未找到 Node.js" -ForegroundColor Red
    Write-Host "请先安装 Node.js (>= 18.0.0): https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# 检查版本
$versionNumber = $nodeVersion -replace 'v', '' -split '\.' | Select-Object -First 1
if ([int]$versionNumber -lt 18) {
    Write-Host "✗ Node.js 版本过低 ($nodeVersion)" -ForegroundColor Red
    Write-Host "需要 Node.js >= 18.0.0" -ForegroundColor Red
    exit 1
}

# 创建目标目录
$skillsDir = "$env:USERPROFILE\.agent\skills"
Write-Host "创建目录: $skillsDir" -ForegroundColor Yellow

if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    Write-Host "✓ 目录创建成功" -ForegroundColor Green
} else {
    Write-Host "目录已存在" -ForegroundColor Gray
}

# 下载或克隆仓库
$tempDir = "$env:TEMP\AVEP-install"
Write-Host "下载 AVEP..." -ForegroundColor Yellow

if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}

# 尝试使用 git clone，如果失败则使用 wget
try {
    git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git $tempDir 2>$null
    Write-Host "✓ 下载完成" -ForegroundColor Green
} catch {
    Write-Host "Git 不可用，尝试直接下载..." -ForegroundColor Yellow
    # TODO: 添加直接下载 ZIP 的逻辑
}

# 复制 skills
Write-Host "安装 Skills..." -ForegroundColor Yellow
Copy-Item -Path "$tempDir\skills\*" -Destination $skillsDir -Recurse -Force
Write-Host "✓ Skills 安装完成" -ForegroundColor Green

# 创建环境变量模板
$envTemplate = "$env:USERPROFILE\.agent\.env.template"
Write-Host "创建环境变量模板..." -ForegroundColor Yellow

$envContent = @"
# AVEP 环境变量配置模板
# 复制此文件为 .env 并填写你的私钥

# 用户私钥（必需）
# USER_PRIVATE_KEY=0x...

# RPC URL（已预设，通常不需要修改）
RPC_URL=https://api.testnet.abs.xyz

# 智能合约地址（已预设）
BASE_TOKEN=0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A
AGW_MINT_PAYMASTER=0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844
BONDING_CURVE_FACTORY=0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e

# 可选：自定义曲线地址
# CURVE_ADDRESS=0x...
"@

Set-Content -Path $envTemplate -Value $envContent
Write-Host "✓ 环境变量模板已创建: $envTemplate" -ForegroundColor Green

# 清理临时文件
Write-Host "清理临时文件..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "已安装的 Skills:" -ForegroundColor Yellow
Get-ChildItem $skillsDir -Directory | ForEach-Object {
    Write-Host "  • $($_.Name)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "1. 查看环境变量模板: $envTemplate" -ForegroundColor Gray
Write-Host "2. 生成测试密钥: 询问 AI '生成一个以太坊密钥对'" -ForegroundColor Gray
Write-Host "3. 开始使用: 询问 AI '领取 BaseToken 空投'" -ForegroundColor Gray
Write-Host ""
Write-Host "文档: https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol" -ForegroundColor Cyan
