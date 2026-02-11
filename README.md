# AVEP - AI Via Ethereum Paymaster

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![zkSync Era](https://img.shields.io/badge/zkSync-Era-8B5CF6)](https://zksync.io/)

[中文文档](README_CN.md) | English

**AVEP** is a collection of AI-powered skills that enable seamless Ethereum transactions via paymaster on zkSync Era testnet. No gas fees required - let AI handle your blockchain interactions!

## 🌟 Features

- **Zero Gas Fees**: All transactions are sponsored via paymaster
- **AI-Powered**: Designed for AI assistants (OpenClaw, Claude, GPT, etc.)
- **Multiple Skills**: 6 ready-to-use blockchain skills
- **Easy Integration**: Install as Skills, MCP server, or use CLI directly
- **Testnet Safe**: All operations run on zkSync Era testnet

## 🎯 Available Skills

| Skill | Description | Use Case |
|-------|-------------|----------|
| **ai-keygen** | Generate Ethereum keypair | Create test wallets |
| **ai-airdrop** | Claim BaseToken airdrop | Get test tokens |
| **ai-create-curve** | Create bonding curve token | Launch new token |
| **ai-buy-curve** | Buy bonding curve tokens | Purchase tokens |
| **ai-sell-curve** | Sell bonding curve tokens | Trade tokens |
| **ai-transfer-curve** | Transfer curve tokens | Send tokens to others |

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18.0.0
- An Ethereum private key (testnet)
- Access to zkSync Era testnet

### Installation Methods

#### Option 1: Install as Skills (Recommended)

**Windows:**
```powershell
irm https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.sh | bash
```

#### Option 2: Install as MCP Server

1. Install the MCP server:
```bash
cd mcp
npm install
```

2. Add to your AI tool's MCP configuration (e.g., `.cursor/mcp.json`):
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

#### Option 3: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git
cd AVEP
```

2. Copy skills to your AI assistant:
```bash
cp -r skills/* ~/.agent/skills/
```

## 📖 Usage Examples

### Generate a Keypair

Ask your AI assistant:
> "Generate a new Ethereum keypair for testing"

The AI will automatically run the `ai-keygen` skill and provide you with an address and private key.

### Claim Airdrop

> "Claim the BaseToken airdrop using my private key 0x..."

### Create and Trade Tokens

> "Create a bonding curve token called 'MyToken' with symbol 'MTK'"

> "Buy 100 curve tokens"

> "Sell 50 curve tokens"

See [examples/](examples/) for more detailed workflows.

## 🏗️ Architecture

```
AVEP
├── skills/              # Individual AI skills
│   ├── ai-keygen/
│   ├── ai-airdrop/
│   ├── ai-create-curve/
│   ├── ai-buy-curve/
│   ├── ai-sell-curve/
│   └── ai-transfer-curve/
├── mcp/                 # MCP server integration
├── examples/            # Usage examples
├── docs/                # Detailed documentation
└── install scripts      # Automated installation
```

## 🔐 Security

- **Never share your private key** with anyone
- Use testnet only for learning and testing
- Private keys are never logged or printed
- See [docs/security.md](docs/security.md) for best practices

## 🛠️ Development

### Running a Skill Manually

```bash
# Example: Running ai-keygen
npx -y -p ts-node@10.9.2 -p ethers@6.15.0 \
  ts-node -e "$(cat skills/ai-keygen/SKILL.md | grep -A 100 '```typescript')"
```

### Network Configuration

- **RPC URL**: `https://api.testnet.abs.xyz`
- **Chain ID**: 2741 (zkSync Era testnet)
- **BaseToken**: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- **Paymaster**: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- **Factory**: `0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e`

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [zkSync Era Documentation](https://era.zksync.io/docs/)
- [Ethers.js Documentation](https://docs.ethers.org/v6/)
- [Installation Guide](INSTALLATION.md)
- [API Reference](docs/api-reference.md)

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/issues)
- **Discussions**: [GitHub Discussions](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions)

## 🗺️ Roadmap

- [ ] Mainnet support
- [ ] Web UI interface
- [ ] Video tutorials
- [ ] More DeFi skills (staking, liquidity pools)
- [ ] Multi-chain support

---

Made with ❤️ for the AI & Web3 community
