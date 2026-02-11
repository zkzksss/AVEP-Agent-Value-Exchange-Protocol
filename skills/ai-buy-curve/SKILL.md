---
name: ai-buy-curve
description: Buy BondingCurve tokens via paymaster. Use when the user asks to approve/buy curve tokens.
---

# AI Buy Curve

购买联合曲线代币，通过 paymaster 支付 gas 费。

## 功能说明

此技能允许用户购买联合曲线代币：
- 自动领取空投（如未领取）
- 批准代币使用
- 购买指定数量的曲线代币
- 无需支付 gas 费

## 使用场景

- 购买代币
- 测试联合曲线交易
- 参与代币经济

## 环境变量

### 固定配置（硬编码）
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`（示例）

### 运行时提供
- `USER_PRIVATE_KEY`: 用户私钥
- `APPROVE_AMOUNT`: 批准额度（可选，默认 10000 tokens）
- `BUY_AMOUNT`: 购买数量（可选，默认 100 tokens）

## 脚本代码

请参考原始设计文档中的完整脚本代码。

## 运行命令

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xYourCurveAddress" \
USER_PRIVATE_KEY="0x..." \
BUY_AMOUNT="100000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-buy-curve.ts
```

## 输出示例

```
[Context]
user: 0x1234...
baseToken: 0x5fcb...
curve: 0xc75d...
[Balances - before]
user baseToken: 1000000000000000000000
user curveToken: 0
[Approve]
[Buy]
[Balances - after]
user baseToken: 900000000000000000000
user curveToken: 100000000000000000000
```

## 注意事项

- 首次使用会自动领取空投
- 需要足够的 BaseToken 余额
- 购买价格根据联合曲线计算
