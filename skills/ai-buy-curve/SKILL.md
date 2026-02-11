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

```typescript
import {config as dotenvConfig} from "dotenv";
import {ethers} from "ethers";
import {Provider, Wallet, utils as zkUtils} from "zksync-ethers";

dotenvConfig();

type Env = {
  RPC_URL: string;
  BASE_TOKEN: string;
  AGW_MINT_PAYMASTER: string;
  USER_PRIVATE_KEY?: string;
  CURVE_ADDRESS?: string;
  APPROVE_AMOUNT?: string;
  BUY_AMOUNT?: string;
};

const env = process.env as Env;

function requireEnv(key: keyof Env): string {
  const value = env[key];
  if (!value) {
    throw new Error(`Missing env ${key}`);
  }
  return value;
}

function envOr(key: keyof Env, fallback: string): string {
  return env[key] || fallback;
}

const baseTokenAbi = [
  "function balanceOf(address) view returns (uint256)",
  "function approve(address,uint256) returns (bool)",
  "function claimAirdrop()",
  "function airdropClaimed(address) view returns (bool)",
];
const curveAbi = [
  "function quoteBuy(uint256) view returns (uint256,uint256)",
  "function buy(uint256,uint256)",
  "function balanceOf(address) view returns (uint256)",
];

function toBigInt(value: string): bigint {
  return BigInt(value);
}

function buildPaymasterInnerInput(chainId: number, paymaster: string, user: string, signer: Wallet): string {
  const domain = {
    name: "AGWMintPaymaster",
    version: "1",
    chainId,
    verifyingContract: paymaster,
  };
  const types = {
    AddressMessage: [{name: "from", type: "address"}],
  };
  const message = {from: user};
  const digest = ethers.TypedDataEncoder.hash(domain, types, message);
  const rawSig = signer.signingKey.sign(digest);
  const v = rawSig.v < 27 ? rawSig.v + 27 : rawSig.v;
  const signature = ethers.Signature.from({r: rawSig.r, s: rawSig.s, v}).serialized;
  const padding = "0x" + "00".repeat(68);
  return ethers.hexlify(ethers.concat([ethers.getBytes(padding), ethers.getBytes(signature)]));
}

async function main() {
  const provider = new Provider(requireEnv("RPC_URL"));
  const chainId = 2741;

  const userKey = requireEnv("USER_PRIVATE_KEY");
  const userWallet = new Wallet(userKey, provider);

  const baseToken = new ethers.Contract(requireEnv("BASE_TOKEN"), baseTokenAbi, provider) as any;
  const curveAddress = requireEnv("CURVE_ADDRESS");
  const curve = new ethers.Contract(curveAddress, curveAbi, provider) as any;

  const user = await userWallet.getAddress();
  const paymasterAddress = requireEnv("AGW_MINT_PAYMASTER");

  console.log("[Context]");
  console.log("user:", user);
  console.log("baseToken:", requireEnv("BASE_TOKEN"));
  console.log("curve:", curveAddress);
  console.log("paymaster:", paymasterAddress);

  const paymasterInnerInput = buildPaymasterInnerInput(chainId, paymasterAddress, user, userWallet);
  const paymasterParams = zkUtils.getPaymasterParams(paymasterAddress, {
    type: "General",
    innerInput: paymasterInnerInput,
  });

  const approveAmount = toBigInt(envOr("APPROVE_AMOUNT", "10000000000000000000000"));
  const buyAmount = toBigInt(envOr("BUY_AMOUNT", "100000000000000000000"));

  console.log("[Balances - before]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());

  const hasClaimed = await baseToken.airdropClaimed(user);
  if (!hasClaimed) {
    console.log("[Airdrop] claim");
    await (
      await baseToken.connect(userWallet).claimAirdrop({
        customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
      })
    ).wait();
  }

  console.log("[Approve]");
  const approveTx = await baseToken.connect(userWallet).approve(curveAddress, approveAmount, {
    customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
  });
  await approveTx.wait();

  console.log("[Buy]");
  const [totalCost] = await curve.quoteBuy(buyAmount);
  const buyTx = await curve.connect(userWallet).buy(buyAmount, totalCost, {
    customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
  });
  await buyTx.wait();

  console.log("[Balances - after]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

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
