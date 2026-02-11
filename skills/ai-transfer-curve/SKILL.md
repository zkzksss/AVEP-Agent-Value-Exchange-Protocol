---
name: ai-transfer-curve
description: Transfer BondingCurve tokens via paymaster. Use when the user asks to transfer curve tokens.
---

# AI Transfer Curve

转账联合曲线代币，通过 paymaster 支付 gas 费。

## 功能说明

此技能允许用户转账联合曲线代币：
- 发送代币给其他地址
- 验证余额变化
- 无需支付 gas 费

## 使用场景

- 发送代币给朋友
- 测试转账功能
- 代币分发

## 环境变量

### 固定配置（硬编码）
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`（示例）

### 运行时提供
- `USER_PRIVATE_KEY`: 用户私钥
- `TRANSFER_TO`: 接收地址（必需）
- `TRANSFER_AMOUNT`: 转账数量（可选，默认 10 tokens）

## 运行命令

```bash
RPC_URL="https://api.testnet.abs.xyz" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xYourCurveAddress" \
USER_PRIVATE_KEY="0x..." \
TRANSFER_TO="0xRecipientAddress" \
TRANSFER_AMOUNT="10000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-transfer-curve.ts
```

## 输出示例

```
[Context]
user: 0x1234...
curve: 0xc75d...
to: 0x5678...
[Balances - before]
user curveToken: 80000000000000000000
to curveToken: 0
[Transfer]
[Balances - after]
user curveToken: 70000000000000000000
to curveToken: 10000000000000000000
```

## 注意事项

- 确保接收地址正确
- 需要持有足够的代币余额
- 转账不可撤销
