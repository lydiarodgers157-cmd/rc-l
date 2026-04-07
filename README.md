# 心理学日程日记 APP

一个基于 Flutter 开发的心理学日程日记应用，帮助用户记录日常行为、觉察本我/自我/超我的关系、追踪时间分配、生成反思日记。

## 功能特性

### 📝 今日记录
- 快速添加行为记录
- 记录时间段、持续时长、心理动机分类
- 情绪状态评估
- 时间浪费标记

### 📊 时间统计
- 今日/本周/本月时间分配饼图
- 本我/自我/超我时间占比分析
- 时间浪费预警（当日浪费超过2小时提醒）
- 趋势图表

### 🧠 心理觉察
- 本我/自我/超我的动态平衡图
- 心理冲突记录与分析
- 基于数据的心理学建议
- 心理学知识科普

### 📔 日记生成
- 自动生成每日回溯日记
- 包含今日概览、心理觉察、时间反思、改善建议
- 支持手动编辑
- 导出为文本

### 📅 历史记录
- 日历视图查看历史
- 点击日期查看当日记录和日记

## 心理学概念

### 本我 (Id)
代表原始欲望和冲动，遵循"快乐原则"，追求即时满足。
典型行为：刷手机、吃零食、看剧等娱乐活动。

### 自我 (Ego)
代表理性和现实考量，遵循"现实原则"，在本我和超我间调解。
典型行为：工作、学习、社交等平衡性活动。

### 超我 (Superego)
代表道德和理想，遵循"道德原则"，追求完美和自我超越。
典型行为：锻炼、帮助他人、学习提升等自律性活动。

## 技术栈

- **框架**: Flutter 3.0+
- **语言**: Dart
- **数据库**: SQLite (sqflite)
- **图表**: fl_chart
- **日历**: table_calendar
- **状态管理**: Provider
- **UI设计**: Material Design 3

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── behavior.dart         # 行为记录模型
│   └── diary.dart            # 日记模型
├── database/                 # 数据库
│   └── database_helper.dart  # 数据库帮助类
├── screens/                  # 页面
│   ├── home_screen.dart      # 首页
│   ├── stats_screen.dart     # 统计页
│   ├── awareness_screen.dart # 觉察页
│   ├── diary_screen.dart     # 日记页
│   └── history_screen.dart   # 历史页
├── widgets/                  # 组件
│   ├── behavior_card.dart    # 行为卡片
│   └── add_behavior_dialog.dart # 添加对话框
├── providers/                # 状态管理
│   └── theme_provider.dart   # 主题提供者
└── utils/                    # 工具类
```

## 安装与运行

### 前置要求

1. 安装 Flutter SDK (>=3.0.0)
2. 安装 Android Studio 或 VS Code
3. 配置 Flutter 环境

### 安装步骤

1. **克隆或下载项目**
   ```bash
   cd 日程日记APP
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   
   连接 Android 设备或启动模拟器，然后运行：
   ```bash
   flutter run
   ```

### 编译 APK

```bash
flutter build apk --release
```

生成的 APK 文件位于：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 数据模型

### behaviors 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| date | TEXT | 日期 (yyyy-MM-dd) |
| time_period | TEXT | 时间段 (上午/下午/晚上) |
| description | TEXT | 行为描述 |
| duration | INTEGER | 持续时长(分钟) |
| drive_type | TEXT | 驱动类型 (id/ego/superego) |
| emotion | INTEGER | 情绪状态 (1-5) |
| is_waste | INTEGER | 是否浪费时间 (0/1) |
| created_at | TEXT | 创建时间 |

### diaries 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| date | TEXT | 日期 (yyyy-MM-dd) |
| content | TEXT | 日记内容 |
| created_at | TEXT | 创建时间 |

## 主要依赖

```yaml
dependencies:
  flutter: sdk
  sqflite: ^2.3.0         # SQLite 数据库
  path: ^1.8.3            # 路径处理
  fl_chart: ^0.66.0       # 图表库
  intl: ^0.18.1           # 国际化
  provider: ^6.1.1        # 状态管理
  shared_preferences: ^2.2.2  # 本地存储
  table_calendar: ^3.0.9  # 日历组件
```

## 使用说明

### 添加行为记录
1. 在首页点击右下角的"添加记录"按钮
2. 填写行为描述
3. 选择时间段（上午/下午/晚上）
4. 设置持续时长
5. 选择心理驱动类型（本我/自我/超我）
6. 评估情绪状态（1-5星）
7. 标记是否浪费时间
8. 点击保存

### 查看统计
- 切换到"统计"标签页
- 查看今日/本周/本月的时间分配
- 关注时间浪费预警

### 心理觉察
- 切换到"觉察"标签页
- 查看本我/自我/超我的平衡状态
- 了解心理冲突记录
- 阅读觉察建议

### 生成日记
- 切换到"日记"标签页
- 点击"自动生成"基于今日记录创建日记
- 或点击"手动编写"自由创作
- 编辑完成后点击保存

### 查看历史
- 切换到"历史"标签页
- 在日历中选择日期
- 查看当日记录和日记

## 注意事项

- 本应用为自用工具，无需登录注册
- 所有数据存储在本地 SQLite 数据库
- 支持深色模式，会跟随系统设置自动切换
- 建议每日记录行为，以获得更准确的统计分析

## 开发者信息

- 开发框架：Flutter
- 设计风格：Material Design 3
- 本地化：支持中文

## 许可证

本项目仅供个人学习和使用。
"# rc-l" 
