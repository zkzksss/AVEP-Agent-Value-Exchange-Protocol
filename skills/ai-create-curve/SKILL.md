---
name: ai-create-curve
description: Create a BondingCurve via paymaster. Use when the user asks to create/issue a new curve token.
---

# AI Create Curve

创建新的联合曲线代币（Bonding Curve Token），通过 paymaster 支付 gas 费。

## 功能说明

此技能允许用户创建自定义的联合曲线代币：
- 设置代币名称和符号
- 配置价格曲线参数
- 自动将代币添加到 paymaster 白名单
- 无需支付 gas 费

## 使用场景

- 发行新的代币
- 创建实验性代币经济模型
- 测试联合曲线机制

## 环境变量

### 固定配置（硬编码）
- `RPC_URL`: `https://api.testnet.abs.xyz`
- `BASE_TOKEN`: `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A`
- `BONDING_CURVE_FACTORY`: `0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e`
- `AGW_MINT_PAYMASTER`: `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844`

### 运行时提供
- `USER_PRIVATE_KEY`: 用户私钥（必需）
- `PAYMASTER_OWNER_PRIVATE_KEY`: Paymaster 所有者私钥（可选，默认使用 USER_PRIVATE_KEY）
- `CURVE_NAME`: 代币名称（可选，默认 "CurveToken"）
- `CURVE_SYMBOL`: 代币符号（可选，默认 "CURVE"）
- `CURVE_MIN_PRICE`: 最小价格（可选）
- `CURVE_MAX_PRICE`: 最大价格（可选）
- `CURVE_K`: 曲线参数 k（可选）
- `CURVE_X0`: 曲线参数 x0（可选）
- `CURVE_FEE_BPS`: 手续费基点（可选，默认 30）

## 脚本代码

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

## 运行命令

```bash
RPC_URL="https://api.testnet.abs.xyz" \
BASE_TOKEN="0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A" \
BONDING_CURVE_FACTORY="0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e" \
AGW_MINT_PAYMASTER="0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844" \
USER_PRIVATE_KEY="0x..." \
CURVE_NAME="MyToken" \
CURVE_SYMBOL="MTK" \
npx --ignore-existing -y -p ts-node@10.9.2 -p ethers@6.15.0 -p zksync-ethers@6.0.0 -p dotenv@16.4.7 \
ts-node /tmp/skill-ai-create-curve.ts
```

## 输出示例

```
[Context]
user: 0x1234...
factory: 0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e
baseToken: 0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A
paymaster: 0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844
[Create Curve]
curve: 0xabcd1234...
[Whitelist]
curve whitelisted: 0xabcd1234...
```

## 参数说明

- **CURVE_NAME**: 代币全称
- **CURVE_SYMBOL**: 代币符号（3-5个字符）
- **CURVE_MIN_PRICE**: 最小购买价格（wei）
- **CURVE_MAX_PRICE**: 最大购买价格（wei）
- **CURVE_K**: 曲线斜率参数
- **CURVE_X0**: 曲线初始供应量
- **CURVE_FEE_BPS**: 交易手续费（基点，100 = 1%）

## 注意事项

- 创建后会自动添加到 paymaster 白名单
- 需要 paymaster owner 权限才能添加白名单
- 记住生成的代币合约地址用于后续交易
