import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/behavior.dart';
import '../models/diary.dart';

/// 日记生成页面
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _diaryController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<Behavior> _todayBehaviors = [];
  Diary? _existingDiary;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _todayBehaviors = await _dbHelper.getBehaviorsByDate(dateStr);
    _existingDiary = await _dbHelper.getDiaryByDate(dateStr);

    if (_existingDiary != null) {
      _diaryController.text = _existingDiary!.content;
    }

    setState(() => _isLoading = false);
  }

  /// 自动生成日记
  void _generateDiary() {
    if (_todayBehaviors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('今日暂无行为记录，无法生成日记')),
      );
      return;
    }

    final diary = _createDiaryContent();
    _diaryController.text = diary;
    setState(() => _isEditing = true);
  }

  /// 创建日记内容
  String _createDiaryContent() {
    final buffer = StringBuffer();
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_selectedDate);
    
    buffer.writeln('# $dateStr 日记\n');
    
    // 今日概览
    buffer.writeln('## 今日概览\n');
    buffer.writeln('共记录 ${_todayBehaviors.length} 项活动，');
    
    int totalMinutes = 0;
    int idTime = 0, egoTime = 0, superegoTime = 0;
    
    for (var behavior in _todayBehaviors) {
      totalMinutes += behavior.duration;
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
    }
    
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    buffer.writeln('总时长 ${hours}小时${mins}分钟。\n');
    
    // 心理觉察
    buffer.writeln('## 心理觉察\n');
    buffer.writeln('### 时间分配');
    buffer.writeln('- 本我驱动：${idTime}分钟');
    buffer.writeln('- 自我驱动：${egoTime}分钟');
    buffer.writeln('- 超我驱动：${superegoTime}分钟\n');
    
    // 行为详情
    buffer.writeln('### 行为记录\n');
    for (var behavior in _todayBehaviors) {
      buffer.writeln('- **${behavior.timePeriod}** ${behavior.description}');
      buffer.writeln('  时长：${behavior.duration}分钟 | ${behavior.driveTypeName} | 情绪：${behavior.emotion}星');
      if (behavior.isWaste) {
        buffer.writeln('  ⚠️ 标记为浪费时间');
      }
    }
    
    // 时间反思
    buffer.writeln('\n## 时间反思\n');
    int wasteTime = _todayBehaviors.where((b) => b.isWaste).fold(0, (sum, b) => sum + b.duration);
    
    if (wasteTime > 120) {
      buffer.writeln('今日浪费时间较多（${wasteTime}分钟），需要反思时间管理策略。');
    } else if (wasteTime > 60) {
      buffer.writeln('今日有一定时间浪费（${wasteTime}分钟），可以进一步优化。');
    } else {
      buffer.writeln('今日时间利用较为合理，浪费时间仅${wasteTime}分钟。');
    }
    
    // 改善建议
    buffer.writeln('\n## 改善建议\n');
    final suggestions = _generateSuggestions(idTime, egoTime, superegoTime);
    for (var suggestion in suggestions) {
      buffer.writeln('- $suggestion');
    }
    
    // 结束语
    buffer.writeln('\n---');
    buffer.writeln('*记录于 ${DateFormat('HH:mm').format(DateTime.now())}*');
    
    return buffer.toString();
  }

  /// 生成改善建议
  List<String> _generateSuggestions(int idTime, int egoTime, int superegoTime) {
    final suggestions = <String>[];
    final total = idTime + egoTime + superegoTime;
    
    if (total == 0) return ['继续保持觉察，记录更多行为'];
    
    final idPercent = idTime / total * 100;
    final egoPercent = egoTime / total * 100;
    final superegoPercent = superegoTime / total * 100;
    
    if (idPercent > 40) {
      suggestions.add('本我驱动占比较高，建议增加理性规划的活动');
    }
    
    if (superegoPercent < 20) {
      suggestions.add('超我驱动时间不足，尝试增加自律性活动');
    }
    
    if (egoPercent > 60) {
      suggestions.add('自我驱动时间较多，注意劳逸结合');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('三者比例相对平衡，继续保持良好的时间管理');
    }
    
    return suggestions;
  }

  /// 保存日记
  Future<void> _saveDiary() async {
    if (_diaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记内容不能为空')),
      );
      return;
    }

    final diary = Diary(
      id: _existingDiary?.id,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      content: _diaryController.text,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _dbHelper.upsertDiary(diary);
    
    setState(() => _isEditing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记已保存')),
      );
    }
    
    _loadData();
  }

  /// 复制日记到剪贴板
  void _copyDiary() {
    Clipboard.setData(ClipboardData(text: _diaryController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日记已复制到剪贴板')),
    );
  }

  /// 导出日记
  void _exportDiary() {
    // 由于是移动应用，导出功能通过复制到剪贴板实现
    _copyDiary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
                _loadData();
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'generate':
                  _generateDiary();
                  break;
                case 'copy':
                  _copyDiary();
                  break;
                case 'export':
                  _exportDiary();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('自动生成'),
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('复制到剪贴板'),
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('导出'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: _saveDiary,
              icon: const Icon(Icons.save),
              label: const Text('保存日记'),
            )
          : null,
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期显示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 快速操作按钮
          if (!_isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generateDiary,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('自动生成日记'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text('手动编写'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 今日记录概览
          if (_todayBehaviors.isNotEmpty) ...[
            Text(
              '今日记录概览',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ..._todayBehaviors.map((behavior) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getDriveColor(behavior.driveType).withOpacity(0.2),
                      child: Icon(
                        Icons.access_time,
                        color: _getDriveColor(behavior.driveType),
                      ),
                    ),
                    title: Text(behavior.description),
                    subtitle: Text(
                      '${behavior.timePeriod} · ${behavior.duration}分钟 · ${behavior.driveTypeName}',
                    ),
                    trailing: Text(
                      '${behavior.emotion}⭐',
                    ),
                  ),
                )),
            const Divider(height: 32),
          ],

          // 日记编辑区
          Text(
            '日记内容',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _diaryController,
            maxLines: 15,
            enabled: _isEditing,
            decoration: InputDecoration(
              hintText: '点击"自动生成"或"手动编写"开始记录日记...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: !_isEditing,
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // 提示信息
          if (!_isEditing && _diaryController.text.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '选择"自动生成"或"手动编写"',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '自动生成将基于今日的行为记录创建日记',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 获取驱动类型颜色
  Color _getDriveColor(String driveType) {
    switch (driveType) {
      case 'id':
        return Colors.red;
      case 'ego':
        return Colors.teal;
      case 'superego':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
