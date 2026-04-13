#!/bin/bash

# 心理学日记APP 快速启动脚本

echo "==================================="
echo "心理学日记APP - 快速启动"
echo "==================================="
echo ""

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误：未检测到 Flutter SDK"
    echo "请先安装 Flutter SDK: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter SDK 已安装"
flutter --version
echo ""

# 安装依赖
echo "📦 正在安装依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装完成"
echo ""

# 检查设备
echo "📱 检查可用设备..."
flutter devices

echo ""
echo "==================================="
echo "选择运行模式："
echo "1) 运行应用（连接设备或模拟器）"
echo "2) 编译 APK"
echo "3) 退出"
echo "==================================="
read -p "请输入选项 (1-3): " choice

case $choice in
    1)
        echo ""
        echo "🚀 正在启动应用..."
        flutter run
        ;;
    2)
        echo ""
        echo "🔨 正在编译 APK..."
        flutter build apk --release
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ APK 编译成功！"
            echo "文件位置: build/app/outputs/flutter-apk/app-release.apk"
        else
            echo "❌ APK 编译失败"
            exit 1
        fi
        ;;
    3)
        echo "👋 退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
