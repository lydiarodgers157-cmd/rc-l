/// 应用常量
class AppConstants {
  // 应用名称
  static const String appName = '心理学日记';
  
  // 数据库名称
  static const String databaseName = 'psychology_diary.db';
  
  // 数据库版本
  static const int databaseVersion = 1;
  
  // 时间浪费预警阈值（分钟）
  static const int wasteTimeWarningThreshold = 120;
  
  // 驱动类型
  static const String driveTypeId = 'id';
  static const String driveTypeEgo = 'ego';
  static const String driveTypeSuperego = 'superego';
  
  // 时间段
  static const List<String> timePeriods = ['上午', '下午', '晚上'];
  
  // 情绪等级
  static const int minEmotion = 1;
  static const int maxEmotion = 5;
  
  // 最小/最大时长（分钟）
  static const int minDuration = 5;
  static const int maxDuration = 240;
}

/// 驱动类型信息
class DriveTypeInfo {
  final String key;
  final String name;
  final String description;
  final String examples;
  final int colorValue;

  const DriveTypeInfo({
    required this.key,
    required this.name,
    required this.description,
    required this.examples,
    required this.colorValue,
  });

  static const List<DriveTypeInfo> all = [
    DriveTypeInfo(
      key: 'id',
      name: '本我驱动',
      description: '欲望、冲动、即时满足',
      examples: '刷手机、吃零食、看剧',
      colorValue: 0xFFFF6B6B,
    ),
    DriveTypeInfo(
      key: 'ego',
      name: '自我驱动',
      description: '理性、现实考量、平衡',
      examples: '工作、学习、社交',
      colorValue: 0xFF4ECDC4,
    ),
    DriveTypeInfo(
      key: 'superego',
      name: '超我驱动',
      description: '道德、理想、自律',
      examples: '锻炼、帮助他人、学习提升',
      colorValue: 0xFF95E1D3,
    ),
  ];
}
