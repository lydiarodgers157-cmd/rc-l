import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';
import '../models/behavior.dart';
import '../models/diary.dart';

/// 历史记录页面
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<Behavior> _selectedDayBehaviors = [];
  Diary? _selectedDayDiary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadDayData(_selectedDay!);
  }

  /// 加载指定日期的数据
  Future<void> _loadDayData(DateTime day) async {
    setState(() => _isLoading = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    _selectedDayBehaviors = await _dbHelper.getBehaviorsByDate(dateStr);
    _selectedDayDiary = await _dbHelper.getDiaryByDate(dateStr);

    setState(() => _isLoading = false);
  }

  /// 获取时间统计
  Map<String, int> _getTimeStats() {
    int idTime = 0, egoTime = 0, superegoTime = 0;
    
    for (var behavior in _selectedDayBehaviors) {
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
    
    return {
      'id': idTime,
      'ego': egoTime,
      'superego': superegoTime,
      'total': idTime + egoTime + superegoTime,
    };
  }

  /// 查看日记详情
  void _viewDiaryDetail() {
    if (_selectedDayDiary == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    DateFormat('yyyy年MM月dd日', 'zh_CN').format(_selectedDay!),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _selectedDayDiary!.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
      ),
      body: Column(
        children: [
          // 日历
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadDayData(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            locale: 'zh_CN',
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(height: 1),
          
          // 当日详情
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDayDetail(),
          ),
        ],
      ),
    );
  }

  /// 构建当日详情
  Widget _buildDayDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          Row(
            children: [
              Text(
                DateFormat('MM月dd日 EEEE', 'zh_CN').format(_selectedDay!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (_selectedDayDiary != null)
                TextButton.icon(
                  onPressed: _viewDiaryDetail,
                  icon: const Icon(Icons.book, size: 18),
                  label: const Text('查看日记'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_selectedDayBehaviors.isEmpty)
            _buildEmptyState()
          else
            _buildBehaviorSummary(),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '当日暂无记录',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建行为摘要
  Widget _buildBehaviorSummary() {
    final stats = _getTimeStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间统计卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip('本我', stats['id']!, Colors.red),
                    _buildStatChip('自我', stats['ego']!, Colors.teal),
                    _buildStatChip('超我', stats['superego']!, Colors.green),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '总计：${stats['total']! ~/ 60}小时${stats['total']! % 60}分钟',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 行为列表
        Text(
          '行为记录 (${_selectedDayBehaviors.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ..._selectedDayBehaviors.map((behavior) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getDriveColor(behavior.driveType).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${behavior.duration}m',
                      style: TextStyle(
                        color: _getDriveColor(behavior.driveType),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                title: Text(behavior.description),
                subtitle: Text(
                  '${behavior.timePeriod} · ${behavior.driveTypeName}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    Text('${behavior.emotion}'),
                    if (behavior.isWaste) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Colors.red[700],
                      ),
                    ],
                  ],
                ),
              ),
            )),

        // 日记卡片
        if (_selectedDayDiary != null) ...[
          const SizedBox(height: 16),
          Text(
            '日记',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: InkWell(
              onTap: _viewDiaryDetail,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '当日日记',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedDayDiary!.content.split('\n').take(5).join('\n') +
                          '...',
                      style: const TextStyle(fontSize: 13),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建统计芯片
  Widget _buildStatChip(String label, int minutes, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${minutes}m',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
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
