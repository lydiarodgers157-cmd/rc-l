import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/behavior.dart';
import '../models/diary.dart';

/// 数据库帮助类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('psychology_diary.db');
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// 创建数据库表
  Future _createDB(Database db, int version) async {
    // 创建行为记录表
    await db.execute('''
      CREATE TABLE behaviors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time_period TEXT NOT NULL,
        description TEXT NOT NULL,
        duration INTEGER NOT NULL,
        drive_type TEXT NOT NULL,
        emotion INTEGER NOT NULL,
        is_waste INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 创建日记表
    await db.execute('''
      CREATE TABLE diaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 创建索引以提升查询性能
    await db.execute('CREATE INDEX idx_behaviors_date ON behaviors(date)');
    await db.execute('CREATE INDEX idx_diaries_date ON diaries(date)');
  }

  // ========== 行为记录相关操作 ==========

  /// 插入行为记录
  Future<int> insertBehavior(Behavior behavior) async {
    final db = await instance.database;
    return await db.insert('behaviors', behavior.toMap());
  }

  /// 获取指定日期的行为记录
  Future<List<Behavior>> getBehaviorsByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'behaviors',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Behavior.fromMap(map)).toList();
  }

  /// 获取日期范围内的行为记录
  Future<List<Behavior>> getBehaviorsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'behaviors',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => Behavior.fromMap(map)).toList();
  }

  /// 更新行为记录
  Future<int> updateBehavior(Behavior behavior) async {
    final db = await instance.database;
    return await db.update(
      'behaviors',
      behavior.toMap(),
      where: 'id = ?',
      whereArgs: [behavior.id],
    );
  }

  /// 删除行为记录
  Future<int> deleteBehavior(int id) async {
    final db = await instance.database;
    return await db.delete(
      'behaviors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取指定日期的时间统计
  Future<Map<String, int>> getTimeStatsByDate(String date) async {
    final db = await instance.database;
    final behaviors = await getBehaviorsByDate(date);

    int idTime = 0;
    int egoTime = 0;
    int superegoTime = 0;
    int wasteTime = 0;

    for (var behavior in behaviors) {
      switch (behavior.driveType) {
        case 'id':
          idTime += behavior.duration;
          break;
        case 'ego':
          egoTime += behavior.duration;
          break;
        case 'superego':
          superegoTime += behavior.duration;
          break;
      }
      if (behavior.isWaste) {
        wasteTime += behavior.duration;
      }
    }

    return {
      'id': idTime,
      'ego': egoTime,
      'superego': superegoTime,
      'total': idTime + egoTime + superegoTime,
      'waste': wasteTime,
    };
  }

  /// 获取本周/本月的统计
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate =
        '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';

    final behaviors = await getBehaviorsByDateRange(startDate,
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');

    Map<String, int> dailyStats = {};
    int idTotal = 0, egoTotal = 0, superegoTime = 0, superegoTotal = 0, wasteTotal = 0;

    for (var behavior in behaviors) {
      final date = behavior.date;
      dailyStats[date] = (dailyStats[date] ?? 0) + behavior.duration;

      switch (behavior.driveType) {
        case 'id':
          idTotal += behavior.duration;
          break;
        case 'ego':
          egoTotal += behavior.duration;
          break;
        case 'superego':
          superegoTime += behavior.duration;
          break;
      }
      if (behavior.isWaste) wasteTotal += behavior.duration;
    }

    return {
      'dailyStats': dailyStats,
      'idTotal': idTotal,
      'egoTotal': egoTotal,
      'superegoTotal': superegoTotal,
      'wasteTotal': wasteTotal,
      'totalTime': idTotal + egoTotal + superegoTotal,
    };
  }

  // ========== 日记相关操作 ==========

  /// 插入或更新日记
  Future<int> upsertDiary(Diary diary) async {
    final db = await instance.database;
    final existing = await getDiaryByDate(diary.date);

    if (existing != null) {
      return await db.update(
        'diaries',
        diary.toMap(),
        where: 'date = ?',
        whereArgs: [diary.date],
      );
    } else {
      return await db.insert('diaries', diary.toMap());
    }
  }

  /// 获取指定日期的日记
  Future<Diary?> getDiaryByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'diaries',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return Diary.fromMap(maps.first);
    }
    return null;
  }

  /// 获取所有日记
  Future<List<Diary>> getAllDiaries() async {
    final db = await instance.database;
    final maps = await db.query(
      'diaries',
      orderBy: 'date DESC',
    );
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  /// 删除日记
  Future<int> deleteDiary(int id) async {
    final db = await instance.database;
    return await db.delete(
      'diaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 关闭数据库
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
