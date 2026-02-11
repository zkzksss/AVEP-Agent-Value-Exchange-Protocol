---
name: ai-sell-curve
description: Sell BondingCurve tokens via paymaster. Use when the user asks to sell curve tokens.
---

# AI Sell Curve

出售联合曲线代币，通过 paymaster 支付 gas 费。

## 功能说明

此技能允许用户出售联合曲线代币：
- 卖出指定数量的曲线代币
- 自动计算卖出价格
- 接收 BaseToken
- 无需支付 gas 费

## 使用场景

- 出售代币获利
- 测试卖出机制
- 流动性管理

## 环境变量

### 固定配置（硬编码）
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`（示例）

### 运行时提供
- `USER_PRIVATE_KEY`: 用户私钥
- `SELL_AMOUNT`: 出售数量（可选，默认 20 tokens）

## 运行命令

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xYourCurveAddress" \
USER_PRIVATE_KEY="0x..." \
SELL_AMOUNT="20000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-sell-curve.ts
```

## 输出示例

```
[Context]
user: 0x1234...
baseToken: 0x5fcb...
curve: 0xc75d...
[Balances - before]
user baseToken: 900000000000000000000
user curveToken: 100000000000000000000
[Sell]
[Balances - after]
user baseToken: 920000000000000000000
user curveToken: 80000000000000000000
```

## 注意事项

- 需要持有足够的曲线代币
- 卖出价格根据联合曲线计算
- 考虑手续费影响
