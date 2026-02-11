---
name: ai-keygen
description: Generate a new Ethereum keypair. Use when the user asks the AI to generate a private key/address for testing.
---

# AI Keygen

生成新的以太坊密钥对，用于测试和开发。

## 功能说明

此技能可以快速生成一个新的以太坊账户，包括：
- 随机私钥
- 对应的公钥地址

## 使用场景

- 创建测试钱包
- 快速获取测试账户
- 学习以太坊密钥机制

## 环境变量

无需任何环境变量。

## 脚本代码

```typescript
import {ethers} from "ethers";

async function main() {
  const wallet = ethers.Wallet.createRandom();
  console.log("address:", wallet.address);
  console.log("privateKey:", wallet.privateKey);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

## 运行命令

```bash
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 ts-node /tmp/skill-ai-keygen.ts
```

## 输出示例

```
address: 0x1234567890abcdef1234567890abcdef12345678
privateKey: 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
```

## 安全提示

> [!WARNING]
> 生成的私钥应妥善保管，不要在生产环境使用测试私钥。

## 注意事项

- 生成的私钥是随机的
- 请将私钥保存在安全的地方
- 测试网私钥不要用于主网
- AI 不会记录或存储你的私钥
