# AVEP - Agent Value Exchange Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![zkSync Era](https://img.shields.io/badge/zkSync-Era-8B5CF6)](https://zksync.io/)

中文文档 | [English](README.md)

**AVEP (Agent Value Exchange Protocol)** 是一个 AI 驱动的代理交易协议技能集合，通过 paymaster 在 zkSync Era 测试网上实现无缝的以太坊交易。零 gas 费 — 让 AI 代理处理你的区块链交互！

## 🌟 功能特性

- **零 Gas 费用**：所有交易通过 paymaster 赞助
- **AI 驱动**：专为 AI 助手设计（OpenClaw、Claude、GPT 等）
- **多种技能**：6 个即用型区块链技能
- **易于集成**：可作为 Skills、MCP 服务器安装，或直接使用 CLI
- **测试网安全**：所有操作在 zkSync Era 测试网上运行

## 🎯 可用技能

| 技能 | 描述 | 使用场景 |
|------|------|---------|
| **ai-keygen** | 生成以太坊密钥对 | 创建测试钱包 |
| **ai-airdrop** | 领取 BaseToken 空投 | 获取测试代币 |
| **ai-create-curve** | 创建联合曲线代币 | 发行新代币 |
| **ai-buy-curve** | 购买联合曲线代币 | 买入代币 |
| **ai-sell-curve** | 出售联合曲线代币 | 交易代币 |
| **ai-transfer-curve** | 转账曲线代币 | 发送代币给他人 |

## 🚀 快速开始

### 前置要求

- Node.js >= 18.0.0
- 以太坊私钥（测试网）
- 访问 zkSync Era 测试网

### 安装方式

#### 方式 1: 作为 Skills 安装（推荐）

**Windows:**
```powershell
irm https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.sh | bash
```

#### 方式 2: 作为 MCP 服务器安装

1. 安装 MCP 服务器：
```bash
cd mcp
npm install
```

2. 添加到你的 AI 工具 MCP 配置中（例如 `.cursor/mcp.json`）：
```json
{
  "mcpServers": {
    "avep": {
      "command": "node",
      "args": ["path/to/AVEP/mcp/server.js"]
    }
  }
}
```

#### 方式 3: 手动安装

1. 克隆仓库：
```bash
git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git
cd AVEP
```

2. 复制 skills 到你的 AI 助手：
```bash
cp -r skills/* ~/.agent/skills/
```

## 📖 使用示例

### 生成密钥对

询问你的 AI 助手：
> "为测试生成一个新的以太坊密钥对"

AI 将自动运行 `ai-keygen` 技能，并为你提供地址和私钥。

### 领取空投

> "使用我的私钥 0x... 领取 BaseToken 空投"

### 创建和交易代币

> "创建一个名为 'MyToken' 符号为 'MTK' 的联合曲线代币"

> "购买 100 个曲线代币"

> "出售 50 个曲线代币"

查看 [examples/](examples/) 了解更详细的工作流程。

## 🏗️ 架构

```
AVEP
├── skills/              # 独立的 AI 技能
│   ├── ai-keygen/
│   ├── ai-airdrop/
│   ├── ai-create-curve/
│   ├── ai-buy-curve/
│   ├── ai-sell-curve/
│   └── ai-transfer-curve/
├── mcp/                 # MCP 服务器集成
├── examples/            # 使用示例
├── docs/                # 详细文档
└── 安装脚本             # 自动化安装
```

## 🔐 安全

- **永远不要分享你的私钥**
- 仅在测试网上用于学习和测试
- 私钥永远不会被记录或打印
- 查看 [docs/security.md](docs/security.md) 了解最佳实践

## 🛠️ 开发

### 手动运行技能

```bash
# 示例：运行 ai-keygen
npx -y -p ts-node@10.9.2 -p ethers@6.15.0 \
  ts-node -e "$(cat skills/ai-keygen/SKILL.md | grep -A 100 '```typescript')"
```

### 网络配置

- **RPC URL**: `https://api.testnet.abs.xyz`
- **Chain ID**: 2741 (zkSync Era 测试网)
- **BaseToken**: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- **Paymaster**: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- **Factory**: `0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e`

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 资源

- [zkSync Era 文档](https://era.zksync.io/docs/)
- [Ethers.js 文档](https://docs.ethers.org/v6/)
- [安装指南](INSTALLATION.md)
- [API 参考](docs/api-reference.md)

## 💬 支持

- **问题反馈**: [GitHub Issues](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/issues)
- **讨论**: [GitHub Discussions](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions)

## 🗺️ 路线图

- [ ] 主网支持
- [ ] Web UI 界面
- [ ] 视频教程
- [ ] 更多 DeFi 技能（质押、流动性池）
- [ ] 多链支持

---

用 ❤️ 为 AI 和 Web3 社区打造
