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

## 脚本代码

```typescript
import {config as dotenvConfig} from "dotenv";
import {ethers} from "ethers";
import {Provider, Wallet, utils as zkUtils} from "zksync-ethers";

dotenvConfig();

type Env = {
  RPC_URL: string;
  AGW_MINT_PAYMASTER: string;
  USER_PRIVATE_KEY?: string;
  CURVE_ADDRESS?: string;
  TRANSFER_TO?: string;
  TRANSFER_AMOUNT?: string;
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

const curveAbi = [
  "function transfer(address,uint256) returns (bool)",
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

  const curveAddress = requireEnv("CURVE_ADDRESS");
  const curve = new ethers.Contract(curveAddress, curveAbi, provider) as any;

  const user = await userWallet.getAddress();
  const paymasterAddress = requireEnv("AGW_MINT_PAYMASTER");
  const to = requireEnv("TRANSFER_TO");

  console.log("[Context]");
  console.log("user:", user);
  console.log("curve:", curveAddress);
  console.log("to:", to);
  console.log("paymaster:", paymasterAddress);

  const paymasterInnerInput = buildPaymasterInnerInput(chainId, paymasterAddress, user, userWallet);
  const paymasterParams = zkUtils.getPaymasterParams(paymasterAddress, {
    type: "General",
    innerInput: paymasterInnerInput,
  });

  const transferAmount = toBigInt(envOr("TRANSFER_AMOUNT", "10000000000000000000"));

  console.log("[Balances - before]");
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());
  console.log("to curveToken:", (await curve.balanceOf(to)).toString());

  console.log("[Transfer]");
  const transferTx = await curve.connect(userWallet).transfer(to, transferAmount, {
    customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
  });
  await transferTx.wait();

  console.log("[Balances - after]");
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());
  console.log("to curveToken:", (await curve.balanceOf(to)).toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

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
