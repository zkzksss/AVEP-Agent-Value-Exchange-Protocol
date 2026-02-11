# 安全最佳实践

使用 AVEP 时的安全建议和最佳实践。

## 私钥管理

### ⚠️ 关键原则

> [!CAUTION]
> **永远不要**分享、公开或提交你的私钥到代码仓库！

### 推荐做法

#### 1. 使用环境变量

```bash
# .env 文件（添加到 .gitignore）
USER_PRIVATE_KEY=0x...
```

#### 2. 测试网与主网分离

- ✅ 使用专门的测试网密钥
- ✅ 永远不要在测试网使用主网密钥
- ✅ 测试密钥中不要存放真实资产

#### 3. 密钥存储

**不推荐**:
- ❌ 硬编码在代码中
- ❌ 提交到 Git
- ❌ 存储在公开位置
- ❌ 通过电子邮件/聊天发送

**推荐**:
- ✅ 使用密钥管理工具（如 1Password、LastPass）
- ✅ 加密存储
- ✅ 使用硬件钱包（生产环境）
- ✅ 环境变量 + .gitignore

#### 4. 权限控制

```bash
# 限制 .env 文件权限
chmod 600 .env
```

---

## 交易安全

### 验证合约地址

在与合约交互前，始终验证地址：

```typescript
// 验证合约地址格式
if (!ethers.isAddress(contractAddress)) {
  throw new Error("Invalid contract address");
}

// 验证合约代码
const code = await provider.getCode(contractAddress);
if (code === "0x") {
  throw new Error("No contract at this address");
}
```

### 交易限额

设置合理的交易限额：

```typescript
// 限制单次交易金额
const MAX_TRANSACTION_AMOUNT = ethers.parseEther("100");

if (amount > MAX_TRANSACTION_AMOUNT) {
  throw new Error("Transaction amount exceeds limit");
}
```

### 滑点保护

购买/出售代币时设置滑点保护：

```typescript
// 设置 5% 滑点容忍度
const slippageTolerance = 0.05;
const minAmount = expectedAmount * (1 - slippageTolerance);
```

---

## 网络安全

### RPC 端点

使用可信的 RPC 端点：

```bash
# 官方端点
RPC_URL=https://api.testnet.abs.xyz

# 或使用知名服务商
# Infura, Alchemy, QuickNode 等
```

### HTTPS

始终使用 HTTPS 连接：

```typescript
// ✅ 正确
const provider = new Provider("https://...");

// ❌ 错误 - 不安全
const provider = new Provider("http://...");
```

---

## 代码安全

### 输入验证

验证所有用户输入：

```typescript
function validateAddress(address: string): boolean {
  return ethers.isAddress(address);
}

function validateAmount(amount: string): boolean {
  try {
    const bn = BigInt(amount);
    return bn > 0n;
  } catch {
    return false;
  }
}
```

### 错误处理

妥善处理错误，避免泄露敏感信息：

```typescript
try {
  // 执行操作
} catch (error) {
  // ❌ 不要暴露完整错误
  // console.log(error);
  
  // ✅ 记录简要信息
  console.error("Transaction failed:", error.message);
}
```

### 依赖安全

定期更新依赖包：

```bash
# 检查过时的包
npm outdated

# 更新依赖
npm update

# 审计安全漏洞
npm audit
npm audit fix
```

---

## AI 助手使用安全

### 敏感信息

与 AI 交互时注意：

**不要**:
- ❌ "我的私钥是 0x123... 请帮我..."
- ❌ 在聊天中粘贴完整私钥
- ❌ 分享助记词

**应该**:
- ✅ "使用环境变量中的私钥"  
- ✅ "私钥已配置，请执行交易"
- ✅ 使用地址标识身份

### 审核交易

在 AI 执行交易前审核：

```
AI: 准备执行以下交易:
    操作: 购买代币
    数量: 100 tokens
    预计成本: 50 BaseToken
    接收地址: 0x1234...
    
您确认执行吗？
```

---

## 智能合约交互

### Gas 限制

设置合理的 gas 限制：

```typescript
const tx = await contract.method({
  gasLimit: 1000000, // 1M gas
});
```

### Paymaster 验证

验证 paymaster 签名：

```typescript
// 确保 paymaster 地址正确
const TRUSTED_PAYMASTER = "0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844";

if (paymasterAddress.toLowerCase() !== TRUSTED_PAYMASTER.toLowerCase()) {
  throw new Error("Untrusted paymaster");
}
```

---

## 监控与日志

### 交易监控

记录所有交易：

```typescript
console.log(`[${new Date().toISOString()}] Transaction submitted`);
console.log(`  From: ${userAddress}`);
console.log(`  To: ${contractAddress}`);
console.log(`  Value: ${amount.toString()}`);
console.log(`  TxHash: ${tx.hash}`);
```

### 异常检测

监控异常行为：

```typescript
// 检测异常大额交易
if (amount > NORMAL_AMOUNT * 10) {
  console.warn("Unusually large transaction detected");
  // 可能需要额外确认
}
```

---

## 紧急响应

### 私钥泄露

如果私钥泄露：

1. **立即停止使用**该地址
2. **创建新地址**
3. **转移所有资产**到新地址
4. **更新所有配置**

### 异常交易

发现异常交易：

1. **停止所有操作**
2. **检查交易详情**（区块浏览器）
3. **联系支持团队**
4. **保存所有证据**

---

## 合规建议

### 了解法规

- 了解所在地区的加密货币法规
- 某些地区可能限制加密货币使用
- 遵守 KYC/AML 要求

### 测试网使用

- AVEP 当前仅支持测试网
- 测试网代币无实际价值
- 不用于生产或商业用途

---

## 检查清单

使用 AVEP 前的安全检查：

- [ ] 私钥存储在安全位置
- [ ] .env 文件已添加到 .gitignore
- [ ] 使用测试网专用密钥
- [ ] 验证所有合约地址
- [ ] 设置合理的交易限额
- [ ] 使用 HTTPS RPC 端点
- [ ] 定期更新依赖包
- [ ] 审核 AI 生成的交易
- [ ] 启用交易日志
- [ ] 了解紧急响应流程

---

## 资源

- [以太坊安全最佳实践](https://consensys.github.io/smart-contract-best-practices/)
- [zkSync 安全文档](https://era.zksync.io/docs/dev/security/)
- [OWASP 区块链安全指南](https://owasp.org/www-project-blockchain/)

## 报告安全问题

如发现安全漏洞，请：

1. **不要**公开披露
2. 发送邮件到: security@example.com
3. 提供详细信息和复现步骤
4. 等待安全团队响应

---

> [!NOTE]
> 安全是一个持续的过程。定期审查和更新你的安全实践。
