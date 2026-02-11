// AVEP 环境验证脚本
import { execSync } from "child_process";

console.log("🔍 AVEP 环境验证");
console.log("================\n");

let errors = 0;
let warnings = 0;

// 检查 Node.js 版本
try {
    console.log("✓ 检查 Node.js 版本...");
    const nodeVersion = process.version;
    const majorVersion = parseInt(nodeVersion.slice(1).split(".")[0]);

    if (majorVersion >= 18) {
        console.log(`  ✓ Node.js ${nodeVersion} (OK)\n`);
    } else {
        console.error(`  ✗ Node.js ${nodeVersion} (需要 >= 18.0.0)\n`);
        errors++;
    }
} catch (error) {
    console.error("  ✗ 无法检查 Node.js 版本\n");
    errors++;
}

// 检查依赖包
console.log("✓ 检查 npm 包...");
const requiredPackages = ["ethers", "zksync-ethers", "ts-node", "dotenv"];

for (const pkg of requiredPackages) {
    try {
        execSync(`npm list ${pkg}`, { stdio: "ignore" });
        console.log(`  ✓ ${pkg}`);
    } catch {
        console.warn(`  ⚠ ${pkg} (未安装，运行时会自动安装)`);
        warnings++;
    }
}
console.log();

// 检查网络连接
console.log("✓ 检查网络连接...");
try {
    const https = await import("https");
    await new Promise<void>((resolve, reject) => {
        https.get("https://api.testnet.abs.xyz", (res) => {
            if (res.statusCode === 200 || res.statusCode === 405) {
                console.log("  ✓ zkSync Era testnet 可访问\n");
                resolve();
            } else {
                console.warn(`  ⚠ zkSync Era testnet 返回状态码 ${res.statusCode}\n`);
                warnings++;
                resolve();
            }
        }).on("error", (e) => {
            console.error(`  ✗ 无法连接到 zkSync Era testnet: ${e.message}\n`);
            errors++;
            reject(e);
        });
    });
} catch (error) {
    console.error("  ✗ 网络检查失败\n");
    errors++;
}

// 检查环境变量
console.log("✓ 检查环境变量...");
const envVars = [
    { name: "USER_PRIVATE_KEY", required: false },
    { name: "RPC_URL", required: false },
];

for (const { name, required } of envVars) {
    if (process.env[name]) {
        console.log(`  ✓ ${name} (已设置)`);
    } else if (required) {
        console.error(`  ✗ ${name} (必需但未设置)`);
        errors++;
    } else {
        console.log(`  ℹ ${name} (未设置，将使用默认值)`);
    }
}
console.log();

// 检查 Skills 目录
console.log("✓ 检查 Skills 安装...");
const fs = await import("fs");
const path = await import("path");
const homeDir = process.env.HOME || process.env.USERPROFILE || "";
const skillsDir = path.join(homeDir, ".agent", "skills");

const expectedSkills = [
    "ai-keygen",
    "ai-airdrop",
    "ai-create-curve",
    "ai-buy-curve",
    "ai-sell-curve",
    "ai-transfer-curve",
];

if (fs.existsSync(skillsDir)) {
    console.log(`  ✓ Skills 目录存在: ${skillsDir}`);

    for (const skill of expectedSkills) {
        const skillPath = path.join(skillsDir, skill);
        const skillMdPath = path.join(skillPath, "SKILL.md");

        if (fs.existsSync(skillMdPath)) {
            console.log(`  ✓ ${skill}`);
        } else {
            console.warn(`  ⚠ ${skill} (未安装或缺少 SKILL.md)`);
            warnings++;
        }
    }
} else {
    console.warn(`  ⚠ Skills 目录不存在: ${skillsDir}`);
    console.warn("    运行 'install.ps1' 或 'install.sh' 进行安装");
    warnings++;
}
console.log();

// 总结
console.log("================");
console.log("验证完成\n");

if (errors === 0 && warnings === 0) {
    console.log("✅ 所有检查通过！");
    console.log("\n开始使用 AVEP:");
    console.log("  1. 询问 AI: '生成一个以太坊密钥对'");
    console.log("  2. 询问 AI: '领取 BaseToken 空投'");
    console.log("  3. 查看文档: README.md");
    process.exit(0);
} else {
    if (errors > 0) {
        console.error(`❌ 发现 ${errors} 个错误`);
    }
    if (warnings > 0) {
        console.warn(`⚠️  发现 ${warnings} 个警告`);
    }
    console.log("\n请解决上述问题后重试。");
    console.log("查看安装指南: INSTALLATION.md");
    process.exit(errors > 0 ? 1 : 0);
}
