/// 行为记录数据模型
class Behavior {
  final int? id;
  final String date;
  final String timePeriod; // 上午/下午/晚上
  final String description;
  final int duration; // 分钟
  final String driveType; // id/ego/superego
  final int emotion; // 1-5星
  final bool isWaste;
  final String createdAt;

  Behavior({
    this.id,
    required this.date,
    required this.timePeriod,
    required this.description,
    required this.duration,
    required this.driveType,
    required this.emotion,
    required this.isWaste,
    required this.createdAt,
  });

  /// 从数据库Map转换
  factory Behavior.fromMap(Map<String, dynamic> map) {
    return Behavior(
      id: map['id'],
      date: map['date'],
      timePeriod: map['time_period'],
      description: map['description'],
      duration: map['duration'],
      driveType: map['drive_type'],
      emotion: map['emotion'],
      isWaste: map['is_waste'] == 1,
      createdAt: map['created_at'],
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time_period': timePeriod,
      'description': description,
      'duration': duration,
      'drive_type': driveType,
      'emotion': emotion,
      'is_waste': isWaste ? 1 : 0,
      'created_at': createdAt,
    };
  }

  /// 获取驱动类型的中文名称
  String get driveTypeName {
    switch (driveType) {
      case 'id':
        return '本我驱动';
      case 'ego':
        return '自我驱动';
      case 'superego':
        return '超我驱动';
      default:
        return '未知';
    }
  }

  /// 获取驱动类型的颜色
  static String getDriveTypeColor(String type) {
    switch (type) {
      case 'id':
        return '#FF6B6B'; // 红色 - 冲动
      case 'ego':
        return '#4ECDC4'; // 青色 - 平衡
      case 'superego':
        return '#95E1D3'; // 绿色 - 理想
      default:
        return '#CCCCCC';
    }
  }

  /// 复制并修改
  Behavior copyWith({
    int? id,
    String? date,
    String? timePeriod,
    String? description,
    int? duration,
    String? driveType,
    int? emotion,
    bool? isWaste,
    String? createdAt,
  }) {
    return Behavior(
      id: id ?? this.id,
      date: date ?? this.date,
      timePeriod: timePeriod ?? this.timePeriod,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      driveType: driveType ?? this.driveType,
      emotion: emotion ?? this.emotion,
      isWaste: isWaste ?? this.isWaste,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
