import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/behavior.dart';

/// 心理觉察页面
class AwarenessScreen extends StatefulWidget {
  const AwarenessScreen({super.key});

  @override
  State<AwarenessScreen> createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends State<AwarenessScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<Behavior> _todayBehaviors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayBehaviors = await _dbHelper.getBehaviorsByDate(today);

    setState(() => _isLoading = false);
  }

  /// 获取三者平衡数据
  Map<String, double> _getBalanceData() {
    int idTime = 0, egoTime = 0, superegoTime = 0;
    
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
    }
    
    final total = idTime + egoTime + superegoTime;
    if (total == 0) return {'id': 0, 'ego': 0, 'superego': 0};
    
    return {
      'id': idTime / total * 100,
      'ego': egoTime / total * 100,
      'superego': superegoTime / total * 100,
    };
  }

  /// 获取冲突记录
  List<Map<String, dynamic>> _getConflicts() {
    final conflicts = <Map<String, dynamic>>[];
    
    for (var behavior in _todayBehaviors) {
      if (behavior.isWaste && behavior.driveType == 'id') {
        conflicts.add({
          'type': '本我冲突',
          'description': '${behavior.description} - 本我冲动导致的时间浪费',
          'severity': 'high',
          'suggestion': '尝试用自我驱动替代，如改为计划性娱乐',
        });
      }
      
      if (behavior.emotion <= 2 && behavior.driveType == 'ego') {
        conflicts.add({
          'type': '自我压力',
          'description': '${behavior.description} - 理性任务带来负面情绪',
          'severity': 'medium',
          'suggestion': '适当调整任务难度或增加休息时间',
        });
      }
      
      if (behavior.emotion >= 4 && behavior.driveType == 'superego') {
        conflicts.add({
          'type': '超我满足',
          'description': '${behavior.description} - 理想行为带来积极情绪',
          'severity': 'positive',
          'suggestion': '继续保持，这是自我提升的源泉',
        });
      }
    }
    
    return conflicts;
  }

  /// 生成觉察建议
  List<String> _generateSuggestions() {
    final balance = _getBalanceData();
    final suggestions = <String>[];
    
    if (balance['id']! > 40) {
      suggestions.add('本我驱动时间占比较高（${balance['id']!.toStringAsFixed(1)}%），建议增加自我驱动的活动');
    }
    
    if (balance['superego']! < 20) {
      suggestions.add('超我驱动时间不足（${balance['superego']!.toStringAsFixed(1)}%），尝试增加自律性活动');
    }
    
    if (balance['ego']! > 60) {
      suggestions.add('自我驱动时间占比较高（${balance['ego']!.toStringAsFixed(1)}%），注意劳逸结合');
    }
    
    if (balance['id']! >= 20 && balance['id']! <= 30 &&
        balance['ego']! >= 40 && balance['ego']! <= 50 &&
        balance['superego']! >= 20 && balance['superego']! <= 30) {
      suggestions.add('恭喜！你的本我、自我、超我处于相对平衡状态，继续保持！');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('继续保持觉察，关注内心三者的平衡与冲突');
    }
    
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心理觉察'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 三者平衡图
                    _buildBalanceCard(),
                    const SizedBox(height: 16),

                    // 冲突记录
                    _buildConflictsCard(),
                    const SizedBox(height: 16),

                    // 觉察建议
                    _buildSuggestionsCard(),
                    const SizedBox(height: 16),

                    // 心理学知识
                    _buildKnowledgeCard(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 构建平衡卡片
  Widget _buildBalanceCard() {
    final balance = _getBalanceData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本我·自我·超我 平衡',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // 三角平衡图
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceItem(
                  '本我',
                  'Id',
                  balance['id']!,
                  Colors.red,
                  Icons.local_fire_department,
                  '欲望与冲动',
                ),
                _buildBalanceItem(
                  '自我',
                  'Ego',
                  balance['ego']!,
                  Colors.teal,
                  Icons.balance,
                  '理性与平衡',
                ),
                _buildBalanceItem(
                  '超我',
                  'Superego',
                  balance['superego']!,
                  Colors.green,
                  Icons.volunteer_activism,
                  '理想与道德',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 平衡状态指示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getBalanceIcon(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getBalanceMessage(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建平衡项
  Widget _buildBalanceItem(
    String title,
    String subtitle,
    double percentage,
    Color color,
    IconData icon,
    String description,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// 获取平衡图标
  IconData _getBalanceIcon() {
    final balance = _getBalanceData();
    final maxDiff = [
      (balance['id']! - 33.33).abs(),
      (balance['ego']! - 33.33).abs(),
      (balance['superego']! - 33.33).abs(),
    ].reduce((a, b) => a > b ? a : b);
    
    if (maxDiff < 10) return Icons.check_circle;
    if (maxDiff < 20) return Icons.info;
    return Icons.warning;
  }

  /// 获取平衡消息
  String _getBalanceMessage() {
    final balance = _getBalanceData();
    final maxDiff = [
      (balance['id']! - 33.33).abs(),
      (balance['ego']! - 33.33).abs(),
      (balance['superego']! - 33.33).abs(),
    ].reduce((a, b) => a > b ? a : b);
    
    if (maxDiff < 10) return '三者相对平衡，状态良好';
    if (maxDiff < 20) return '略有失衡，建议关注调整';
    return '明显失衡，需要重点调整';
  }

  /// 构建冲突卡片
  Widget _buildConflictsCard() {
    final conflicts = _getConflicts();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '冲突记录',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (conflicts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无明显的心理冲突记录',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...conflicts.map((conflict) => _buildConflictItem(conflict)),
          ],
        ),
      ),
    );
  }

  /// 构建冲突项
  Widget _buildConflictItem(Map<String, dynamic> conflict) {
    Color color;
    IconData icon;
    
    switch (conflict['severity']) {
      case 'high':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'positive':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                conflict['type'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(conflict['description']),
          const SizedBox(height: 4),
          Text(
            '建议：${conflict['suggestion']}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建建议卡片
  Widget _buildSuggestionsCard() {
    final suggestions = _generateSuggestions();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '觉察建议',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 构建心理学知识卡片
  Widget _buildKnowledgeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '心理学知识',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildKnowledgeItem(
              '本我 (Id)',
              '代表原始欲望和冲动，遵循"快乐原则"，追求即时满足。',
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildKnowledgeItem(
              '自我 (Ego)',
              '代表理性和现实考量，遵循"现实原则"，在本我和超我间调解。',
              Colors.teal,
            ),
            const SizedBox(height: 8),
            _buildKnowledgeItem(
              '超我 (Superego)',
              '代表道德和理想，遵循"道德原则"，追求完美和自我超越。',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建知识项
  Widget _buildKnowledgeItem(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
