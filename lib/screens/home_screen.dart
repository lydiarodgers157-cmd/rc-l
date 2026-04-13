import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../database/database_helper.dart';
import '../models/behavior.dart';
import '../widgets/behavior_card.dart';
import '../widgets/add_behavior_dialog.dart';
import 'stats_screen.dart';
import 'awareness_screen.dart';
import 'diary_screen.dart';
import 'history_screen.dart';

/// 主页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<Behavior> _todayBehaviors = [];
  bool _isLoading = true;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载今日数据
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _todayBehaviors = await _dbHelper.getBehaviorsByDate(dateStr);
    
    setState(() => _isLoading = false);
  }

  /// 添加行为记录
  Future<void> _addBehavior() async {
    final result = await showDialog<Behavior>(
      context: context,
      builder: (context) => AddBehaviorDialog(date: _selectedDate),
    );

    if (result != null) {
      await _dbHelper.insertBehavior(result);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('行为记录已添加')),
        );
      }
    }
  }

  /// 删除行为记录
  Future<void> _deleteBehavior(Behavior behavior) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true && behavior.id != null) {
      await _dbHelper.deleteBehavior(behavior.id!);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已删除')),
        );
      }
    }
  }

  /// 获取今日统计
  Map<String, int> _getTodayStats() {
    int idTime = 0, egoTime = 0, superegoTime = 0, wasteTime = 0;
    
    for (var behavior in _todayBehaviors) {
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
      'waste': wasteTime,
      'total': idTime + egoTime + superegoTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTodayPage(),
      const StatsScreen(),
      const AwarenessScreen(),
      const DiaryScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: '觉察',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '日记',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '历史',
          ),
        ],
      ),
    );
  }

  /// 构建今日页面
  Widget _buildTodayPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_selectedDate),
        ),
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
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayBehaviors.isEmpty
              ? _buildEmptyState()
              : _buildBehaviorList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBehavior,
        icon: const Icon(Icons.add),
        label: const Text('添加记录'),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无记录',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加今日行为记录',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建行为列表
  Widget _buildBehaviorList() {
    final stats = _getTodayStats();
    
    return Column(
      children: [
        // 今日统计卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日概览',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('本我', stats['id']!, Colors.red),
                      _buildStatItem('自我', stats['ego']!, Colors.teal),
                      _buildStatItem('超我', stats['superego']!, Colors.green),
                      _buildStatItem(
                        '浪费时间',
                        stats['waste']!,
                        stats['waste']! > 120 ? Colors.red : Colors.grey,
                      ),
                    ],
                  ),
                  if (stats['waste']! > 120) ...[
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '今日浪费时间已超过2小时，请注意调整！',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // 行为记录列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _todayBehaviors.length,
            itemBuilder: (context, index) {
              final behavior = _todayBehaviors[index];
              return BehaviorCard(
                behavior: behavior,
                onDelete: () => _deleteBehavior(behavior),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, int minutes, Color color) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              hours > 0 ? '${hours}h' : '${mins}m',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
