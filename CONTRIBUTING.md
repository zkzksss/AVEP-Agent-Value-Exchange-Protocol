# 贡献指南

感谢你考虑为 AVEP 做出贡献！

## 如何贡献

### 报告问题

发现 bug？请：

1. 在 [Issues](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/issues) 中搜索是否已存在相同问题
2. 如果没有，创建新 issue
3. 提供详细信息：
   - 问题描述
   - 复现步骤
   - 预期行为
   - 实际行为
   - 环境信息（OS、Node.js 版本等）

### 提出功能建议

有好的想法？请：

1. 在 [Discussions](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions) 中讨论
2. 说明功能用途和价值
3. 等待社区反馈
4. 如获认可，创建 feature request issue

### 提交代码

1. **Fork 仓库**
   ```bash
   git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git
   cd AVEP
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **编写代码**
   - 遵循现有代码风格
   - 添加必要的注释
   - 更新相关文档

4. **测试**
   ```bash
   npm test
   npm run verify
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   ```

6. **推送到 GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 描述你的更改
   - 链接相关 issue
   - 等待代码审查

## 代码规范

### 命名约定

- 变量/函数：`camelCase`
- 常量：`UPPER_SNAKE_CASE`
- 文件/目录：`kebab-case`

### TypeScript

```typescript
// 使用类型注解
function transfer(to: string, amount: bigInt): Promise<void> {
  // ...
}

// 避免 any
// ❌ const result: any = ...
// ✅ const result: TransactionReceipt = ...
```

### 注释

```typescript
/**
 * 购买联合曲线代币
 * @param amount 购买数量（wei）
 * @returns 交易收据
 */
async function buyCurve(amount: bigint): Promise<TransactionReceipt> {
  // 验证输入
  if (amount <= 0n) {
    throw new Error("Amount must be positive");
  }
  
  // 执行购买
  // ...
}
```

## 提交消息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更改
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 添加测试
- `chore`: 构建/工具更改

### 示例

```
feat(ai-airdrop): 添加重试机制

当网络不稳定时，自动重试空投领取操作。

Closes #123
```

## 文档贡献

### 改进文档

- 修正拼写/语法错误
- 改进说明清晰度
- 添加示例
- 翻译文档

### 文档风格

- 使用简洁明了的语言
- 提供代码示例
- 包含预期输出
- 标注重要提示（使用 GitHub alerts）

## 社区准则

### 行为规范

- 尊重他人
- 建设性讨论
- 欢迎新手
- 耐心回答问题

### 不可接受的行为

- 骚扰或歧视
- 恶意攻击
- 发布他人私密信息
- 其他不专业行为

## 开发设置

### 环境准备

```bash
# 安装依赖
npm install

# 运行测试
npm test

# 代码检查
npm run lint

# 格式化代码
npm run format
```

### 测试

添加新功能时：

1. 编写单元测试
2. 编写集成测试
3. 手动测试
4. 更新文档

## 许可证

提交代码即表示你同意以 MIT 许可证发布你的贡献。

## 问题？

- 💬 [GitHub Discussions](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/discussions)
- 📧 Email: dev@example.com
- 📖 [文档](https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol)

---

再次感谢你的贡献！🎉
