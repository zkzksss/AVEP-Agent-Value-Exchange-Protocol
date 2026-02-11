---
name: ai-airdrop
description: Claim BaseToken airdrop via paymaster. Use when the user asks to claim airdrop via paymaster.
---

# AI Airdrop

通过 paymaster 领取 BaseToken 空投，无需支付 gas 费。

## 功能说明

此技能允许用户在 zkSync Era 测试网上领取 BaseToken 空投：
- 自动检查是否已领取
- 通过 paymaster 支付 gas 费
- 验证领取结果

## 使用场景

- 获取测试代币
- 开始使用 AVEP 技能
- 测试 paymaster 功能

## 环境变量

### 固定配置（硬编码）
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`

### 运行时提供
- `USER_PRIVATE_KEY`: 用户私钥（不会被打印）

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
};

const env = process.env as Env;

function requireEnv(key: keyof Env): string {
  const value = env[key];
  if (!value) {
    throw new Error(`Missing env ${key}`);
  }
  return value;
}

const baseTokenAbi = [
  "function balanceOf(address) view returns (uint256)",
  "function claimAirdrop()",
  "function airdropClaimed(address) view returns (bool)",
];

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
  const paymasterAddress = requireEnv("AGW_MINT_PAYMASTER");
  const user = await userWallet.getAddress();

  console.log("[Context]");
  console.log("user:", user);
  console.log("baseToken:", requireEnv("BASE_TOKEN"));
  console.log("paymaster:", paymasterAddress);

  const paymasterInnerInput = buildPaymasterInnerInput(chainId, paymasterAddress, user, userWallet);
  const paymasterParams = zkUtils.getPaymasterParams(paymasterAddress, {
    type: "General",
    innerInput: paymasterInnerInput,
  });

  console.log("[Balances - before]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());

  const hasClaimed = await baseToken.airdropClaimed(user);
  if (hasClaimed) {
    console.log("[Airdrop] already claimed");
    return;
  }

  console.log("[Airdrop] claim");
  const claimTx = await baseToken.connect(userWallet).claimAirdrop({
    customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
  });
  await claimTx.wait();

  console.log("[Paymaster ETH Proof - Claim]");
  console.log("txHash:", claimTx.hash);
  console.log("[Balances - after]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());
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
USER_PRIVATE_KEY="0x..." \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-airdrop.ts
```

## 输出示例

```
[Context]
user: 0x1234...
baseToken: 0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A
paymaster: 0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844
[Balances - before]
user baseToken: 0
[Airdrop] claim
[Paymaster ETH Proof - Claim]
txHash: 0xabcd...
[Balances - after]
user baseToken: 1000000000000000000000
```

## 注意事项

- 每个地址只能领取一次空投
- 已领取的地址会自动跳过
- 交易通过 paymaster 支付，用户无需 ETH
