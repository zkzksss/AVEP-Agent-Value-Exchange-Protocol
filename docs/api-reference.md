# AVEP API 参考

AVEP 技能的详细 API 参考文档。

## 环境变量

所有 skills 共享的环境变量：

### 网络配置

| 变量名 | 类型 | 必需 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `RPC_URL` | string | 否 | `https://api.testnet.abs.xyz` | zkSync Era testnet RPC 端点 |

### 合约地址

| 变量名 | 类型 | 必需 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `BASE_TOKEN` | address | 否 | `0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A` | BaseToken 合约地址 |
| `AGW_MINT_PAYMASTER` | address | 否 | `0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844` | Paymaster 合约地址 |
| `BONDING_CURVE_FACTORY` | address | 否 | `0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e` | 工厂合约地址 |
| `CURVE_ADDRESS` | address | 视情况 | - | 曲线代币合约地址 |

### 用户凭证

| 变量名 | 类型 | 必需 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `USER_PRIVATE_KEY` | string | 是 | - | 用户私钥（0x 开头） |
| `PAYMASTER_OWNER_PRIVATE_KEY` | string | 否 | USER_PRIVATE_KEY | Paymaster 所有者私钥 |

---

## Skills API

### ai-keygen

生成新的以太坊密钥对。

#### 输入

无需输入参数。

#### 输出

```typescript
{
  address: string;      // 以太坊地址
  privateKey: string;   // 私钥（0x 开头）
}
```

#### 示例

```bash
npx -y -p ts-node@10.9.2 -p ethers@6.15.0 \
  ts-node skill-ai-keygen.ts
```

---

### ai-airdrop

领取 BaseToken 空投。

#### 输入

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `USER_PRIVATE_KEY` | string | 是 | 用户私钥 |

#### 输出

```typescript
{
  txHash: string;           // 交易哈希
  balanceBefore: bigint;    // 领取前余额
  balanceAfter: bigint;     // 领取后余额
}
```

#### 行为

- 检查是否已领取
- 如已领取，跳过并返回
- 如未领取，发起交易
- 通过 paymaster 支付 gas

---

### ai-create-curve

创建联合曲线代币。

#### 输入

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `USER_PRIVATE_KEY` | string | 是 | - | 用户私钥 |
| `CURVE_NAME` | string | 否 | "CurveToken" | 代币名称 |
| `CURVE_SYMBOL` | string | 否 | "CURVE" | 代币符号 |
| `CURVE_MIN_PRICE` | bigint | 否 | 0.01 ether | 最小价格 |
| `CURVE_MAX_PRICE` | bigint | 否 | 1.0 ether | 最大价格 |
| `CURVE_K` | bigint | 否 | 0.5 ether | 曲线参数 k |
| `CURVE_X0` | bigint | 否 | 1000 ether | 初始供应量 |
| `CURVE_FEE_BPS` | bigint | 否 | 30 | 手续费（基点） |

#### 输出

```typescript
{
  curveAddress: string;     // 曲线代币合约地址
  creator: string;          // 创建者地址
  whitelisted: boolean;     // 是否已加入白名单
}
```

---

### ai-buy-curve

购买联合曲线代币。

#### 输入

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `USER_PRIVATE_KEY` | string | 是 | - | 用户私钥 |
| `CURVE_ADDRESS` | address | 是 | - | 曲线代币地址 |
| `APPROVE_AMOUNT` | bigint | 否 | 10000 ether | 批准额度 |
| `BUY_AMOUNT` | bigint | 否 | 100 ether | 购买数量 |

#### 输出

```typescript
{
  approveTxHash: string;    // 批准交易哈希
  buyTxHash: string;        // 购买交易哈希
  cost: bigint;             // 实际成本
  received: bigint;         // 收到的代币数量
}
```

---

### ai-sell-curve

出售联合曲线代币。

#### 输入

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `USER_PRIVATE_KEY` | string | 是 | - | 用户私钥 |
| `CURVE_ADDRESS` | address | 是 | - | 曲线代币地址 |
| `SELL_AMOUNT` | bigint | 否 | 20 ether | 出售数量 |

#### 输出

```typescript
{
  sellTxHash: string;       // 出售交易哈希
  payout: bigint;           // 获得的 BaseToken
  fee: bigint;              // 手续费
}
```

---

### ai-transfer-curve

转账联合曲线代币。

#### 输入

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `USER_PRIVATE_KEY` | string | 是 | - | 用户私钥 |
| `CURVE_ADDRESS` | address | 是 | - | 曲线代币地址 |
| `TRANSFER_TO` | address | 是 | - | 接收地址 |
| `TRANSFER_AMOUNT` | bigint | 否 | 10 ether | 转账数量 |

#### 输出

```typescript
{
  transferTxHash: string;   // 转账交易哈希
  from: string;             // 发送者地址
  to: string;               // 接收者地址
  amount: bigint;           // 转账数量
}
```

---

## 智能合约接口

### BaseToken

```solidity
interface IBaseToken {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function claimAirdrop() external;
    function airdropClaimed(address account) external view returns (bool);
}
```

### BondingCurve

```solidity
interface IBondingCurve {
    function balanceOf(address account) external view returns (uint256);
    function quoteBuy(uint256 amount) external view returns (uint256 cost, uint256 fee);
    function quoteSell(uint256 amount) external view returns (uint256 payout, uint256 fee, uint256 netPayout);
    function buy(uint256 amount, uint256 maxCost) external;
    function sell(uint256 amount, uint256 minPayout) external;
    function transfer(address to, uint256 amount) external returns (bool);
}
```

### BondingCurveFactory

```solidity
interface IBondingCurveFactory {
    event CurveCreated(address indexed proxy, address indexed creator);
    
    function createCurve(
        string memory name,
        string memory symbol,
        address baseToken,
        address feeRecipient,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 k,
        uint256 x0,
        uint256 feeBps
    ) external returns (address);
}
```

### AGWMintPaymaster

```solidity
interface IAGWMintPaymaster {
    function setList(address[] memory addrs, bool isWhitelisted) external;
}
```

---

## 错误代码

| 错误代码 | 描述 | 解决方案 |
|----------|------|----------|
| `Missing env USER_PRIVATE_KEY` | 缺少私钥 | 设置 USER_PRIVATE_KEY 环境变量 |
| `Invalid contract address` | 合约地址无效 | 验证地址格式 |
| `Insufficient balance` | 余额不足 | 领取空投或确保有足够余额 |
| `Already claimed` | 已领取空投 | 跳过此步骤 |
| `Slippage too high` | 滑点过高 | 调整购买/出售数量 |
| `Unauthorized` | 无权限 | 确认 paymaster owner 私钥正确 |

---

## 类型定义

### TransactionReceipt

```typescript
interface TransactionReceipt {
  hash: string;
  from: string;
  to: string;
  blockNumber: number;
  gasUsed: bigint;
  status: number;  // 1 = success, 0 = failure
}
```

### PaymasterParams

```typescript
interface PaymasterParams {
  paymaster: string;
  paymasterInput: string;
}
```

---

## 工具函数

### buildPaymasterInnerInput

构建 paymaster 签名输入。

```typescript
function buildPaymasterInnerInput(
  chainId: number,
  paymaster: string,
  user: string,
  signer: Wallet
): string
```

### toBigInt

字符串转 BigInt。

```typescript
function toBigInt(value: string): bigint
```

---

## 网络信息

### zkSync Era Testnet

- **Chain ID**: 2741
- **RPC**: https://api.testnet.abs.xyz
- **浏览器**: https://explorer.testnet.abs.xyz
- **Faucet**: https://faucet.testnet.abs.xyz

---

## 限制

| 项目 | 限制 |
|------|------|
| 最大 gas | 10,000,000 |
| 空投数量 | 1000 BaseToken（每地址一次） |
| 最小交易 | 0.01 token |
| 最大手续费 | 10% (1000 bps) |

---

## 示例代码

### 完整购买流程

```typescript
import {Provider, Wallet} from "zksync-ethers";
import {ethers} from "ethers";

const provider = new Provider("https://api.testnet.abs.xyz");
const wallet = new Wallet(process.env.USER_PRIVATE_KEY!, provider);

// 1. 领取空投
const baseToken = new ethers.Contract(BASE_TOKEN_ADDRESS, baseTokenAbi, wallet);
await baseToken.claimAirdrop();

// 2. 批准使用
await baseToken.approve(CURVE_ADDRESS, ethers.parseEther("1000"));

// 3. 购买代币
const curve = new ethers.Contract(CURVE_ADDRESS, curveAbi, wallet);
const [cost] = await curve.quoteBuy(ethers.parseEther("100"));
await curve.buy(ethers.parseEther("100"), cost);
```

---

## 更新日志

查看 [CHANGELOG.md](../CHANGELOG.md) 了解版本更新。

## 支持

- 📖 [文档](../README.md)
- 💬 [讨论](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions)
- 🐛 [问题](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/issues)
