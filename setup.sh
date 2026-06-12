#!/bin/bash
# ===================================================
# CAssistant iOS 项目初始化脚本
# 如果使用 xcodegen，运行此脚本自动生成 Xcode 项目
# ===================================================

echo "========================================"
echo "CAssistant iOS 项目初始化"
echo "========================================"

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查 xcodegen
if command -v xcodegen &> /dev/null; then
    echo "使用 xcodegen 生成 Xcode 项目..."
    cd "$PROJECT_DIR"
    xcodegen generate
    echo "✅ Xcode 项目已生成: $PROJECT_DIR/CAssistant.xcodeproj"
else
    echo "未安装 xcodegen。安装方式："
    echo "  brew install xcodegen"
    echo ""
    echo "或者直接使用已提供的 project.yml 手动映射："
    echo "  1. 在 Xcode 中新建项目"
    echo "  2. 将 CAssistant 目录拖入项目"
    echo ""
    echo "项目文件结构："
    echo "  $PROJECT_DIR/"
    echo "  ├── CAssistant/"
    echo "  │   ├── CAssistantApp.swift        # 主入口"
    echo "  │   ├── Info.plist                  # 配置"
    echo "  │   ├── CAssistant.entitlements     # 权限"
    echo "  │   ├── Models/                     # 数据模型"
    echo "  │   ├── Services/                   # 服务层"
    echo "  │   ├── Utils/                      # 工具类"
    echo "  │   ├── Resources/                  # 资源文件"
    echo "  │   └── Views/                      # 视图层"
    echo "  │       ├── ContentView.swift       # 主视图+导航"
    echo "  │       ├── Analysis/               # 分析工具"
    echo "  │       ├── Viewers/                # 查看器"
    echo "  │       ├── AIChat/                 # AI功能"
    echo "  │       ├── Project/                # 项目管理"
    echo "  │       ├── Tools/                  # 工具"
    echo "  │       └── Settings/               # 设置"
    echo "  ├── build.sh                        # 打包脚本"
    echo "  ├── project.yml                     # xcodegen配置"
    echo "  ├── Package.swift                   # SPM配置"
    echo "  └── README.md                       # 说明文档"
fi