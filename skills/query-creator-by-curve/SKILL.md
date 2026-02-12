---
name: query-creator-by-curve
description: Query the creator address of a BondingCurve using BondingCurveFactory.getCreatorByCurve (creatorByCurve). Use when the user asks who created a curve or the creator of a curve address.
---

# Query Creator by Curve

查询 `BondingCurveFactory.creatorByCurve`：根据 curve 代理地址返回其创建者地址。

## Boundary and Inputs

### Fixed by deployment (hard-coded)

- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BONDING_CURVE_FACTORY`: `0x265790fA3E3239887Af948C789A6A914f2A93380`

### Provided by the agent per run

- `CURVE`（必填）：要查询的 BondingCurve 代理地址

## Contract

- `getCreatorByCurve(address curve) view returns (address)`

## Script / Run Command

使用现有脚本 `scripts/utils/queryCurveCreator.ts`，或 `queryCurvesByCreator.ts` 仅传 `CURVE`：

```bash
CURVE="0xCurveAddress" npx -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 ts-node scripts/utils/queryCurveCreator.ts
```

## Output Expectations

- 输出 `curve:` 与 `creator:`；若 curve 非本工厂创建，`creator` 为零地址。
