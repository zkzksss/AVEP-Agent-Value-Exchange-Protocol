---
title: Combined AI Skills
---

# Combined AI Skills

## ai-airdrop

---
name: ai-airdrop
description: Claim BaseToken airdrop via paymaster. Use when the user asks to claim airdrop via paymaster.
---

# AI Airdrop Claim

## Boundary and Inputs

### Fixed by deployment (hard-coded)
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844` (whitelist disabled by default)

### Provided by the agent per run
- `USER_PRIVATE_KEY` (do not print)
- `PAYMASTER_OWNER_PRIVATE_KEY` (optional; defaults to `USER_PRIVATE_KEY` for whitelisting)

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-airdrop.ts`):

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

## Run Command

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
USER_PRIVATE_KEY="0x..." \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-airdrop.ts
```

## Output Expectations

- Report the claim transaction hash.
- Do not echo or log the private key.

---

## ai-buy-curve

---
name: ai-buy-curve
description: Buy BondingCurve tokens via paymaster. Use when the user asks to approve/buy curve tokens.
---

# AI Buy Curve Tokens

## Boundary and Inputs

### Fixed by deployment (hard-coded)
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`

### Provided by the agent per run
- `USER_PRIVATE_KEY` (do not print)
- `APPROVE_AMOUNT` (optional; default is in script)
- `BUY_AMOUNT` (optional; default is in script)

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-buy-curve.ts`):

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

## Run Command

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173" \
USER_PRIVATE_KEY="0x..." APPROVE_AMOUNT="10000000000000000000000" BUY_AMOUNT="100000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-buy-curve.ts
```

## Output Expectations

- Report the approve/buy transaction hashes.
- Do not echo or log the private key.

---

## ai-create-curve

---
name: ai-create-curve
description: Create a BondingCurve via paymaster. Use when the user asks to create/issue a new curve token.
---

# AI Create Curve

## Boundary and Inputs

### Fixed by deployment (hard-coded)
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `BONDING_CURVE_FACTORY`: `0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`

### Provided by the agent per run
- `USER_PRIVATE_KEY` (do not print)
- `CURVE_NAME` (optional; default is in script)
- `CURVE_SYMBOL` (optional; default is in script)
- `CURVE_MIN_PRICE` (optional; default is in script)
- `CURVE_MAX_PRICE` (optional; default is in script)
- `CURVE_K` (optional; default is in script)
- `CURVE_X0` (optional; default is in script)
- `CURVE_FEE_BPS` (optional; default is in script)

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-create-curve.ts`):

```typescript
import {config as dotenvConfig} from "dotenv";
import {ethers} from "ethers";
import {Provider, Wallet, utils as zkUtils} from "zksync-ethers";

dotenvConfig();

type Env = {
  RPC_URL: string;
  BASE_TOKEN: string;
  BONDING_CURVE_FACTORY: string;
  AGW_MINT_PAYMASTER: string;
  USER_PRIVATE_KEY?: string;
  PAYMASTER_OWNER_PRIVATE_KEY?: string;
  CURVE_NAME?: string;
  CURVE_SYMBOL?: string;
  CURVE_MIN_PRICE?: string;
  CURVE_MAX_PRICE?: string;
  CURVE_K?: string;
  CURVE_X0?: string;
  CURVE_FEE_BPS?: string;
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

const factoryAbi = [
  "event CurveCreated(address proxy,address creator)",
  "function createCurve(string,string,address,address,uint256,uint256,uint256,uint256,uint256)",
];
const paymasterAbi = ["function setList(address[] addrs, bool bools)"];

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
  const paymasterOwnerKey = envOr("PAYMASTER_OWNER_PRIVATE_KEY", userKey);
  const paymasterOwnerWallet = new Wallet(paymasterOwnerKey, provider);

  const factory = new ethers.Contract(requireEnv("BONDING_CURVE_FACTORY"), factoryAbi, provider) as any;
  const paymasterAddress = requireEnv("AGW_MINT_PAYMASTER");
  const paymaster = new ethers.Contract(paymasterAddress, paymasterAbi, provider) as any;

  const user = await userWallet.getAddress();
  console.log("[Context]");
  console.log("user:", user);
  console.log("factory:", requireEnv("BONDING_CURVE_FACTORY"));
  console.log("baseToken:", requireEnv("BASE_TOKEN"));
  console.log("paymaster:", paymasterAddress);

  const paymasterInnerInput = buildPaymasterInnerInput(chainId, paymasterAddress, user, userWallet);
  const paymasterParams = zkUtils.getPaymasterParams(paymasterAddress, {
    type: "General",
    innerInput: paymasterInnerInput,
  });

  const curveName = envOr("CURVE_NAME", "CurveToken");
  const curveSymbol = envOr("CURVE_SYMBOL", "CURVE");
  const minPrice = toBigInt(envOr("CURVE_MIN_PRICE", "10000000000000000"));
  const maxPrice = toBigInt(envOr("CURVE_MAX_PRICE", "1000000000000000000"));
  const k = toBigInt(envOr("CURVE_K", "500000000000000000"));
  const x0 = toBigInt(envOr("CURVE_X0", "1000000000000000000000"));
  const feeBps = toBigInt(envOr("CURVE_FEE_BPS", "30"));

  console.log("[Create Curve]");
  const createTx = await factory.connect(userWallet).createCurve(
    curveName,
    curveSymbol,
    requireEnv("BASE_TOKEN"),
    user,
    minPrice,
    maxPrice,
    k,
    x0,
    feeBps,
    {customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT}}
  );
  const createReceipt = await createTx.wait();
  const createEvents = createReceipt.logs
    .map((log: ethers.Log) => {
      try {
        return factory.interface.parseLog(log);
      } catch {
        return null;
      }
    })
    .filter(Boolean);
  const curveAddress = createEvents.length
    ? (createEvents[0] as ethers.LogDescription).args[0]
    : null;
  if (!curveAddress) {
    throw new Error("CurveCreated not found");
  }
  console.log("curve:", curveAddress);

  console.log("[Whitelist]");
  const whitelistTx = await paymaster.connect(paymasterOwnerWallet).setList([curveAddress], true);
  await whitelistTx.wait();
  console.log("curve whitelisted:", curveAddress);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

## Run Command

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
BONDING_CURVE_FACTORY="0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
USER_PRIVATE_KEY="0x..." PAYMASTER_OWNER_PRIVATE_KEY="0x..." CURVE_NAME="CurveToken" CURVE_SYMBOL="CURVE" \
CURVE_MIN_PRICE="10000000000000000" CURVE_MAX_PRICE="1000000000000000000" \
CURVE_K="500000000000000000" CURVE_X0="1000000000000000000000" CURVE_FEE_BPS="30" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-create-curve.ts
```

## Output Expectations

- Report the created curve address from the script output.
- Report that the curve was whitelisted.
- Do not echo or log the private key.

---

## ai-keygen

---
name: ai-keygen
description: Generate a new Ethereum keypair. Use when the user asks the AI to generate a private key/address for testing.
---

# AI Keygen

## Boundary and Inputs

No environment variables required.

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-keygen.ts`):

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

## Run Command

```bash
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 ts-node /tmp/skill-ai-keygen.ts
```

## Output Expectations

- Prints `address` and `privateKey`.
- Treat the private key as sensitive; do not log it elsewhere.

---

## ai-sell-curve

---
name: ai-sell-curve
description: Sell BondingCurve tokens via paymaster. Use when the user asks to sell curve tokens.
---

# AI Sell Curve Tokens

## Boundary and Inputs

### Fixed by deployment (hard-coded)
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`

### Provided by the agent per run
- `USER_PRIVATE_KEY` (do not print)
- `SELL_AMOUNT` (optional; default is in script)

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-sell-curve.ts`):

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
  SELL_AMOUNT?: string;
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

const baseTokenAbi = ["function balanceOf(address) view returns (uint256)"];
const curveAbi = [
  "function quoteSell(uint256) view returns (uint256,uint256,uint256)",
  "function sell(uint256,uint256)",
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

  const sellAmount = toBigInt(envOr("SELL_AMOUNT", "20000000000000000000"));

  console.log("[Balances - before]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());

  console.log("[Sell]");
  const [payout] = await curve.quoteSell(sellAmount);
  const sellTx = await curve.connect(userWallet).sell(sellAmount, payout, {
    customData: {paymasterParams, gasPerPubdata: zkUtils.DEFAULT_GAS_PER_PUBDATA_LIMIT},
  });
  await sellTx.wait();

  console.log("[Balances - after]");
  console.log("user baseToken:", (await baseToken.balanceOf(user)).toString());
  console.log("user curveToken:", (await curve.balanceOf(user)).toString());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

## Run Command

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173" \
USER_PRIVATE_KEY="0x..." SELL_AMOUNT="20000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-sell-curve.ts
```

## Output Expectations

- Report the sell transaction hash.
- Do not echo or log the private key.

---

## ai-transfer-curve

---
name: ai-transfer-curve
description: Transfer BondingCurve tokens via paymaster. Use when the user asks to transfer curve tokens.
---

# AI Transfer Curve Tokens

## Boundary and Inputs

### Fixed by deployment (hard-coded)
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`
- `CURVE_ADDRESS`: `0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173`

### Provided by the agent per run
- `USER_PRIVATE_KEY` (do not print)
- `TRANSFER_TO` (required)
- `TRANSFER_AMOUNT` (optional; default is in script)

## Script Content

Write this script to a local file before running (example path: `/tmp/skill-ai-transfer-curve.ts`):

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

## Run Command

```bash
RPC_URL="https://api.testnet.abs.xyz" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
CURVE_ADDRESS="0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173" \
USER_PRIVATE_KEY="0x..." TRANSFER_TO="0xRecipient" TRANSFER_AMOUNT="10000000000000000000" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-transfer-curve.ts
```

## Output Expectations

- Report the transfer transaction hash.
- Do not echo or log the private key.