# 快速入门指南

## 环境准备

### 1. 安装 Flutter SDK

访问 [Flutter 官网](https://flutter.dev/docs/get-started/install) 下载并安装 Flutter SDK。

#### Windows:
1. 下载 Flutter SDK 压缩包
2. 解压到 `C:\flutter`
3. 添加 `C:\flutter\bin` 到系统环境变量 PATH
4. 运行 `flutter doctor` 检查环境

#### macOS:
```bash
brew install flutter
```

#### Linux:
```bash
sudo snap install flutter --classic
```

### 2. 安装 IDE

推荐使用以下任一 IDE：
- **Android Studio** (推荐): 包含完整的 Android 开发工具
- **VS Code** + Flutter 插件: 轻量级选择

### 3. 配置 Android 环境

1. 安装 Android Studio
2. 打开 Android Studio -> SDK Manager
3. 安装 Android SDK、Android SDK Command-line Tools
4. 创建一个 Android 模拟器（AVD）

## 运行项目

### 方式一：使用启动脚本（推荐）

#### Windows:
双击运行 `start.bat`

#### macOS/Linux:
```bash
chmod +x start.sh
./start.sh
```

### 方式二：命令行运行

1. 进入项目目录：
```bash
cd 日程日记APP
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行应用：
```bash
flutter run
```

4. 编译 APK：
```bash
flutter build apk --release
```

### 方式三：使用 IDE

#### VS Code:
1. 打开项目文件夹
2. 按 F5 或点击 Run -> Start Debugging
3. 选择设备（模拟器或真机）

#### Android Studio:
1. 打开项目
2. 选择设备
3. 点击运行按钮

## 常见问题

### Q: flutter doctor 报错
**A:** 根据提示修复问题，通常需要：
- 安装 Android SDK
- 接受 Android licenses: `flutter doctor --android-licenses`
- 安装 Xcode（仅 macOS）

### Q: 无法找到设备
**A:** 
- 确保已启动 Android 模拟器
- 或连接真机并开启 USB 调试模式
- 运行 `flutter devices` 检查

### Q: 依赖安装失败
**A:** 
- 检查网络连接
- 使用中国镜像（如需要）
- 删除 `.dart_tool` 文件夹后重试

### Q: 编译失败
**A:**
- 确保 Android SDK 版本符合要求
- 运行 `flutter clean` 清理缓存
- 更新 Flutter SDK: `flutter upgrade`

## 项目结构说明

```
日程日记APP/
├── lib/                    # Dart 源代码
│   ├── main.dart          # 应用入口
│   ├── models/            # 数据模型
│   ├── database/          # 数据库操作
│   ├── screens/           # 页面
│   ├── widgets/           # 组件
│   ├── providers/         # 状态管理
│   └── utils/             # 工具类
├── android/               # Android 原生配置
├── ios/                   # iOS 原生配置
├── test/                  # 测试文件
├── pubspec.yaml           # 依赖配置
└── README.md              # 项目说明
```

## 开发调试

### 热重载
在运行时按 `r` 热重载，按 `R` 热重启

### 查看日志
```bash
flutter logs
```

### 分析代码
```bash
flutter analyze
```

### 格式化代码
```bash
flutter format .
```

## 下一步

1. ✅ 运行项目
2. 📝 在首页添加第一条行为记录
3. 📊 查看时间统计
4. 🧠 体验心理觉察功能
5. 📔 生成你的第一篇日记

## 获取帮助

- Flutter 官方文档: https://flutter.dev/docs
- Flutter 中文网: https://flutter.cn
- Flutter 社区: https://github.com/flutter/flutter

---

祝你使用愉快！ 🎉
