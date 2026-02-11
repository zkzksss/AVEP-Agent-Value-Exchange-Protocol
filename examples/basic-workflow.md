# AVEP 基础工作流程

本文档演示如何使用 AVEP 完成一个完整的代币创建、交易流程。

## 前置准备

确保你已经：
1. ✅ 安装了 AVEP skills
2. ✅ 配置了环境变量（可选）
3. ✅ 可以访问支持 AI 的开发环境

## 工作流程

### 步骤 1: 生成测试密钥

向你的 AI 助手说：

> "生成一个新的以太坊密钥对"

**AI 将自动**:
- 运行 `ai-keygen` skill
- 生成随机私钥和地址
- 显示结果

**输出示例**:
```
address: 0x1234567890abcdef1234567890abcdef12345678
privateKey: 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
```

> [!WARNING]
> 妥善保存你的私钥！后续步骤需要使用。

---

### 步骤 2: 领取空投

向 AI 说：

> "使用私钥 0xabcdef... 领取 BaseToken 空投"

**AI 将自动**:
- 运行 `ai-airdrop` skill
- 检查是否已领取
- 如未领取，通过 paymaster 发起交易
- 显示交易哈希和余额

**输出示例**:
```
[Context]
user: 0x1234...
[Balances - before]
user baseToken: 0
[Airdrop] claim
txHash: 0xabcd1234...
[Balances - after]
user baseToken: 1000000000000000000000
```

你现在拥有 1000 个 BaseToken！

---

### 步骤 3: 创建联合曲线代币

向 AI 说：

> "创建一个名为 'MyAwesomeToken' 符号为 'MAT' 的联合曲线代币"

**AI 将自动**:
- 运行 `ai-create-curve` skill
- 使用你的私钥部署新代币合约
- 将代币添加到 paymaster 白名单
- 返回代币合约地址

**输出示例**:
```
[Create Curve]
curve: 0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173
[Whitelist]
curve whitelisted: 0xc75ddFED013a90fC28dA953D01Ec9B1872Ce0173
```

> [!NOTE]
> 记住这个合约地址！后续交易需要使用。

---

### 步骤 4: 购买代币

向 AI 说：

> "使用曲线地址 0xc75d... 购买 100 个代币"

**AI 将自动**:
- 运行 `ai-buy-curve` skill
- 批准 BaseToken 使用
- 计算购买成本
- 执行购买交易
- 显示余额变化

**输出示例**:
```
[Balances - before]
user baseToken: 1000000000000000000000
user curveToken: 0
[Approve]
[Buy]
[Balances - after]
user baseToken: 900000000000000000000
user curveToken: 100000000000000000000
```

---

### 步骤 5: 出售代币

向 AI 说：

> "出售 50 个曲线代币"

**AI 将自动**:
- 运行 `ai-sell-curve` skill
- 计算卖出价格
- 执行卖出交易
- 显示余额变化

**输出示例**:
```
[Balances - before]
user baseToken: 900000000000000000000
user curveToken: 100000000000000000000
[Sell]
[Balances - after]
user baseToken: 920000000000000000000
user curveToken: 50000000000000000000
```

---

### 步骤 6: 转账代币

向 AI 说：

> "转账 10 个曲线代币到地址 0x5678..."

**AI 将自动**:
- 运行 `ai-transfer-curve` skill
- 验证地址和余额
- 执行转账交易
- 显示双方余额变化

**输出示例**:
```
[Transfer]
[Balances - after]
user curveToken: 40000000000000000000
to curveToken: 10000000000000000000
```

---

## 完整示例对话

```
你: 生成一个以太坊密钥对
AI: 已生成密钥对：
    地址: 0x1234...
    私钥: 0xabcd...

你: 使用这个私钥领取空投
AI: 正在领取空投...
    ✓ 交易成功！txHash: 0x...
    当前余额: 1000 BaseToken

你: 创建一个名为 MyToken 的联合曲线代币
AI: 正在创建代币...
    ✓ 代币创建成功！
    合约地址: 0xc75d...

你: 购买 100 个 MyToken
AI: 正在购买...
    ✓ 购买成功！
    花费: 100 BaseToken
    获得: 100 MyToken

你: 出售 50 个
AI: 正在出售...
    ✓ 出售成功！
    获得: 45 BaseToken (扣除手续费)
    剩余: 50 MyToken
```

## 进阶用法

### 自定义参数

创建代币时可以自定义更多参数：

> "创建代币，名称 'SpecialToken'，符号 'SPT'，最小价格 0.01，最大价格 1.0，手续费 0.5%"

### 批量操作

> "购买 3 个不同的曲线代币，每个 100 个"

### 查看状态

> "查看我的 BaseToken 和 MyToken 余额"

## 注意事项

1. **网络费用**: 所有交易通过 paymaster 支付，你无需持有 ETH
2. **价格波动**: 联合曲线价格会随供应量变化
3. **手续费**: 每次交易有 0.3% 的手续费（可配置）
4. **测试网**: 所有操作在测试网进行，代币无实际价值

## 下一步

- 查看 [高级交易示例](advanced-trading.md)
- 了解 [API 参考](../docs/api-reference.md)
- 学习 [安全最佳实践](../docs/security.md)

## 常见问题

**Q: 私钥是否安全？**
A: AI 不会存储或记录你的私钥，仅用于签名交易。

**Q: 可以在主网使用吗？**
A: 目前仅支持测试网，主网支持在开发中。

**Q: 交易失败怎么办？**
A: 检查余额、网络连接、合约地址是否正确。查看 [故障排除](../INSTALLATION.md#故障排除)。

**Q: 可以创建多个代币吗？**
A: 可以！你可以创建任意数量的联合曲线代币。
