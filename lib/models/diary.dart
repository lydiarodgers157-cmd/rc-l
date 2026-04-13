/// 日记数据模型
class Diary {
  final int? id;
  final String date;
  final String content;
  final String createdAt;

  Diary({
    this.id,
    required this.date,
    required this.content,
    required this.createdAt,
  });

  /// 从数据库Map转换
  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      date: map['date'],
      content: map['content'],
      createdAt: map['created_at'],
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'content': content,
      'created_at': createdAt,
    };
  }

  /// 复制并修改
  Diary copyWith({
    int? id,
    String? date,
    String? content,
    String? createdAt,
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
