#!/bin/bash
# AVEP 一键安装脚本 (Linux/macOS)
# 使用方法: curl -fsSL https://raw.githubusercontent.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol/main/install.sh | bash

set -e

echo "=================================="
echo "  AVEP 安装程序"
echo "  AI Via Ethereum Paymaster"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 检查 Node.js
echo -e "${YELLOW}检查 Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js 已安装: $NODE_VERSION${NC}"
    
    # 检查版本
    VERSION_NUMBER=$(echo $NODE_VERSION | sed 's/v//' | cut -d. -f1)
    if [ "$VERSION_NUMBER" -lt 18 ]; then
        echo -e "${RED}✗ Node.js 版本过低 ($NODE_VERSION)${NC}"
        echo -e "${RED}需要 Node.js >= 18.0.0${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ 未找到 Node.js${NC}"
    echo -e "${RED}请先安装 Node.js (>= 18.0.0): https://nodejs.org/${NC}"
    exit 1
fi

# 创建目标目录
SKILLS_DIR="$HOME/.agent/skills"
echo -e "${YELLOW}创建目录: $SKILLS_DIR${NC}"

if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    echo -e "${GREEN}✓ 目录创建成功${NC}"
else
    echo -e "${GRAY}目录已存在${NC}"
fi

# 下载或克隆仓库
TEMP_DIR="/tmp/AVEP-install"
echo -e "${YELLOW}下载 AVEP...${NC}"

if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# 尝试使用 git clone
if command -v git &> /dev/null; then
    git clone https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol.git "$TEMP_DIR" 2>/dev/null || {
        echo -e "${RED}Git clone 失败，请检查网络连接${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ 下载完成${NC}"
else
    echo -e "${RED}未找到 git，请先安装 git${NC}"
    exit 1
fi

# 复制 skills
echo -e "${YELLOW}安装 Skills...${NC}"
cp -r "$TEMP_DIR/skills/"* "$SKILLS_DIR/"
echo -e "${GREEN}✓ Skills 安装完成${NC}"

# 创建环境变量模板
ENV_TEMPLATE="$HOME/.agent/.env.template"
echo -e "${YELLOW}创建环境变量模板...${NC}"

cat > "$ENV_TEMPLATE" << 'EOF'
# AVEP 环境变量配置模板
# 复制此文件为 .env 并填写你的私钥

# 用户私钥（必需）
# USER_PRIVATE_KEY=0x...

# RPC URL（已预设，通常不需要修改）
RPC_URL=https://api.testnet.abs.xyz

# 智能合约地址（已预设）
BASE_TOKEN=0x5fcb2f5E96010F8A94CC1295851a74A6Ae97875A
AGW_MINT_PAYMASTER=0xA9B24BE89a93f7026095EF0a9165E4CAcC9FC844
BONDING_CURVE_FACTORY=0x21A5aFbf495Cd9C9750fb26831AB03Da91415b6e

# 可选：自定义曲线地址
# CURVE_ADDRESS=0x...
EOF

echo -e "${GREEN}✓ 环境变量模板已创建: $ENV_TEMPLATE${NC}"

# 清理临时文件
echo -e "${YELLOW}清理临时文件...${NC}"
rm -rf "$TEMP_DIR"

echo ""
echo -e "${CYAN}==================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${CYAN}==================================${NC}"
echo ""
echo -e "${YELLOW}已安装的 Skills:${NC}"
ls -1 "$SKILLS_DIR" | sed 's/^/  • /'
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo -e "${GRAY}1. 查看环境变量模板: $ENV_TEMPLATE${NC}"
echo -e "${GRAY}2. 生成测试密钥: 询问 AI '生成一个以太坊密钥对'${NC}"
echo -e "${GRAY}3. 开始使用: 询问 AI '领取 BaseToken 空投'${NC}"
echo ""
echo -e "${CYAN}文档: https://github.com/zkzksss/AVEP-Agent-Value-Exchange-Protocol${NC}"
