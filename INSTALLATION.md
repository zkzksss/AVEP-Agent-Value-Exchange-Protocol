# AVEP 安装指南

本文档提供详细的 AVEP 安装说明和故障排除指南。

## 系统要求

### 必需
- **Node.js** >= 18.0.0
- **npm** (通常随 Node.js 一起安装)
- 网络连接（访问 zkSync Era 测试网）

### 推荐
- **Git** (用于克隆仓库)
- **支持 AI 的开发环境** (Cursor、VS Code 等)

## 安装方法

### 方法 1: 一键安装（推荐）

#### Windows (PowerShell)

以管理员权限打开 PowerShell：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.ps1 | iex
```

#### Linux / macOS

打开终端：

```bash
curl -fsSL https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.sh | bash
```

### 方法 2: 手动安装

#### 1. 克隆仓库

```bash
git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git
cd AVEP
```

#### 2. 安装依赖（可选）

```bash
npm install
```

#### 3. 复制 Skills

**Windows:**
```powershell
xcopy /E /I skills %USERPROFILE%\.agent\skills
```

**Linux/macOS:**
```bash
cp -r skills/* ~/.agent/skills/
```

### 方法 3: 作为 MCP 服务器安装

#### 1. 安装 MCP 服务器

```bash
cd mcp
npm install
npm run build
```

#### 2. 配置 AI 工具

在你的 AI 工具配置文件中添加 MCP 服务器（例如 `.cursor/mcp.json`）：

```json
{
  "mcpServers": {
    "avep": {
      "command": "node",
      "args": ["F:/AVEP/mcp/dist/server.js"],
      "env": {
        "RPC_URL": "https://api.testnet.abs.xyz",
        "BASE_TOKEN": "0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A",
        "AGW_MINT_PAYMASTER": "0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844",
        "BONDING_CURVE_FACTORY": "0x265790fA3E3239887Af948C789A6A914f2A93380"
      }
    }
  }
}
```

## 环境配置

### 创建 .env 文件

在项目根目录或 `~/.agent/` 目录中创建 `.env` 文件：

```bash
# 复制模板
cp .env.template .env

# 编辑配置
nano .env  # 或使用你喜欢的编辑器
```

### 配置项说明

```env
# 必需：你的以太坊私钥（测试网）
USER_PRIVATE_KEY=0x...

# 可选：网络配置（已有默认值）
RPC_URL=https://api.testnet.abs.xyz

# 可选：合约地址（已有默认值）
BASE_TOKEN=0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A
AGW_MINT_PAYMASTER=0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844
BONDING_CURVE_FACTORY=0x265790fA3E3239887Af948C789A6A914f2A93380
```

## 验证安装

### 运行验证脚本

```bash
npm run verify
```

或手动测试：

```bash
# 测试 keygen
npx -y -p ts-node@10.9.2 -p ethers@6.15.0 \
  ts-node -e "$(cat skills/ai-keygen/SKILL.md | sed -n '/```typescript/,/```/p' | sed '1d;$d')"
```

### 检查 Skills 安装

**Windows:**
```powershell
dir $env:USERPROFILE\.agent\skills
```

**Linux/macOS:**
```bash
ls -l ~/.agent/skills/
```

应该看到以下目录：
- ai-keygen
- ai-airdrop
- ai-create-curve
- ai-buy-curve
- ai-sell-curve
- ai-transfer-curve

## 故障排除

### Node.js 版本问题

**症状**: 提示 Node.js 版本过低

**解决方案**:
1. 访问 [nodejs.org](https://nodejs.org/) 下载最新 LTS 版本
2. 安装后重启终端
3. 验证版本: `node --version`

### 权限错误

**Windows:**
```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

**Linux/macOS:**
```bash
# 使用 sudo（如需要）
sudo bash install.sh

# 或修复权限
chmod +x install.sh
```

### 网络连接问题

**症状**: 无法连接到 zkSync Era 测试网

**解决方案**:
1. 检查网络连接
2. 尝试使用 VPN
3. 检查防火墙设置
4. 验证 RPC URL: `curl https://api.testnet.abs.xyz`

### Skills 未被识别

**症状**: AI 助手找不到 AVEP skills

**解决方案**:
1. 确认 skills 已复制到正确位置: `~/.agent/skills/`
2. 检查每个 skill 目录包含 `SKILL.md` 文件
3. 重启 AI 助手
4. 查看 AI 助手的 skill 加载日志

### 私钥问题

**症状**: "Missing env USER_PRIVATE_KEY" 错误

**解决方案**:
1. 确保 `.env` 文件存在
2. 检查私钥格式: 必须以 `0x` 开头
3. 或在运行时直接提供: `USER_PRIVATE_KEY=0x... npx ...`

### Gas 费用问题

**症状**: "Insufficient gas" 错误

**解决方案**:
1. 确认 paymaster 地址正确
2. 检查网络连接
3. 验证合约未被暂停
4. 查看测试网状态

## 更新 AVEP

### 使用 Git

```bash
cd AVEP
git pull origin main
cp -r skills/* ~/.agent/skills/
```

### 手动更新

1. 下载最新版本
2. 重新运行安装脚本
3. 或手动复制新的 skill 文件

## 卸载

### 删除 Skills

**Windows:**
```powershell
Remove-Item -Recurse -Force $env:USERPROFILE\.agent\skills\ai-*
```

**Linux/macOS:**
```bash
rm -rf ~/.agent/skills/ai-*
```

### 删除项目

```bash
rm -rf AVEP
```

## 获取帮助

- **文档**: [GitHub README](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol)
- **问题反馈**: [GitHub Issues](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/issues)
- **讨论**: [GitHub Discussions](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions)

## 下一步

安装完成后，查看:
- [快速开始示例](examples/basic-workflow.md)
- [API 参考](docs/api-reference.md)
- [安全最佳实践](docs/security.md)
