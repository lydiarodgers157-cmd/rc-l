@echo off
chcp 65001 >nul
title 心理学日记APP - 快速启动

echo ===================================
echo 心理学日记APP - 快速启动
echo ===================================
echo.

:: 检查 Flutter 是否安装
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：未检测到 Flutter SDK
    echo 请先安装 Flutter SDK: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter SDK 已安装
flutter --version
echo.

:: 安装依赖
echo 📦 正在安装依赖...
flutter pub get

if errorlevel 1 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)

echo ✅ 依赖安装完成
echo.

:: 检查设备
echo 📱 检查可用设备...
flutter devices

echo.
echo ===================================
echo 选择运行模式：
echo 1) 运行应用（连接设备或模拟器）
echo 2) 编译 APK
echo 3) 退出
echo ===================================
set /p choice="请输入选项 (1-3): "

if "%choice%"=="1" goto run
if "%choice%"=="2" goto build
if "%choice%"=="3" goto end
echo ❌ 无效选项
pause
exit /b 1

:run
echo.
echo 🚀 正在启动应用...
flutter run
goto end

:build
echo.
echo 🔨 正在编译 APK...
flutter build apk --release

if errorlevel 1 (
    echo ❌ APK 编译失败
    pause
    exit /b 1
)

echo.
echo ✅ APK 编译成功！
echo 文件位置: build\app\outputs\flutter-apk\app-release.apk
goto end

:end
pause
