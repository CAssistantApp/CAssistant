#!/bin/bash
# ===================================================
# CAssistant iOS/iPadOS 打包脚本
# 生成可安装的 .ipa 二进制文件
# ===================================================

echo "========================================"
echo "CAssistant iOS/iPadOS 打包脚本"
echo "========================================"

PROJECT_NAME="CAssistant"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$PROJECT_DIR/dist"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
IPA_PATH="$OUTPUT_DIR/$PROJECT_NAME.ipa"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}项目目录: $PROJECT_DIR${NC}"

# 检查 Xcode 是否安装
if ! xcode-select -p &> /dev/null; then
    echo -e "${RED}错误: 未安装 Xcode 或命令行工具${NC}"
    echo "请从 Mac App Store 安装 Xcode 15+"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${GREEN}✓ 检测到: $XCODE_VERSION${NC}"

# 创建输出目录
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# 清理旧构建
echo -e "\n${YELLOW}清理旧的构建文件...${NC}"
rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# 步骤1: 清理并构建
echo -e "\n${YELLOW}[1/4] 清理项目...${NC}"
xcodebuild clean -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release 2>&1 | tail -5

# 步骤2: 归档
echo -e "\n${YELLOW}[2/4] 归档项目...${NC}"
xcodebuild archive -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE="Automatic" \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" 2>&1 | tail -10

if [ $? -ne 0 ]; then
    echo -e "${RED}错误: 归档失败${NC}"
    echo -e "${YELLOW}尝试无签名构建...${NC}"
    
    # 无签名构建（适用于越狱设备或测试）
    xcodebuild build -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
        -scheme "$PROJECT_NAME" \
        -configuration Release \
        -sdk iphoneos \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO 2>&1 | tail -10
fi

# 步骤3: 导出 IPA
echo -e "\n${YELLOW}[3/4] 导出 IPA...${NC}"
if [ -d "$ARCHIVE_PATH" ]; then
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$OUTPUT_DIR" \
        -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist" 2>&1 | tail -5
fi

# 检查 IPA 是否生成
if [ -f "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    echo -e "\n${GREEN}========================================"
    echo "✅ 打包成功!"
    echo "📦 IPA: $IPA_PATH"
    echo "📏 大小: $IPA_SIZE"
    echo "========================================${NC}"
else
    # 即使没有签名，也提供 .app 文件
    APP_PATH=$(find "$BUILD_DIR" -name "*.app" -type d 2>/dev/null | head -1)
    if [ -n "$APP_PATH" ]; then
        echo -e "\n${YELLOW}⚠ IPA 未生成（需要开发者签名）${NC}"
        echo -e "${GREEN}✓ 已生成 .app 包: $APP_PATH${NC}"
        echo ""
        echo "=== 手动签名并生成 IPA ==="
        echo "1. 打开 Xcode -> 选择项目 -> 配置签名"
        echo "2. Product -> Archive -> Distribute App"
        echo ""
        echo "=== 或者使用以下命令行签名 ==="
        echo "codesign -f -s \"iPhone Distribution: Your Name\" --entitlements entitlements.plist \"$APP_PATH\""
        echo "mkdir -p Payload && cp -r \"$APP_PATH\" Payload/"
        echo "zip -r \"$IPA_PATH\" Payload/"
    else
        echo -e "${RED}错误: 构建输出未找到${NC}"
        echo -e "${YELLOW}请在 Xcode 中直接打开项目构建${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}提示: 在 Xcode 中打开 $PROJECT_DIR/$PROJECT_NAME.xcodeproj 直接运行${NC}"
echo "========================================"