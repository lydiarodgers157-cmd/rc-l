import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/behavior.dart';

/// 时间统计页面
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<Behavior> _todayBehaviors = [];
  List<Behavior> _weekBehaviors = [];
  bool _isLoading = true;
  int _selectedPeriod = 0; // 0: 今日, 1: 本周, 2: 本月

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

    // 获取本周数据
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
    final endDate = DateFormat('yyyy-MM-dd').format(now);
    _weekBehaviors = await _dbHelper.getBehaviorsByDateRange(startDate, endDate);

    setState(() => _isLoading = false);
  }

  /// 获取时间统计
  Map<String, int> _getTimeStats(List<Behavior> behaviors) {
    int idTime = 0, egoTime = 0, superegoTime = 0, wasteTime = 0;
    
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
      'waste': wasteTime,
      'total': idTime + egoTime + superegoTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('时间统计'),
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
                    // 时间段选择
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('今日')),
                        ButtonSegment(value: 1, label: Text('本周')),
                        ButtonSegment(value: 2, label: Text('本月')),
                      ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (Set<int> selection) {
                        setState(() => _selectedPeriod = selection.first);
                      },
                    ),
                    const SizedBox(height: 24),

                    // 时间分配饼图
                    _buildPieChartCard(),
                    const SizedBox(height: 16),

                    // 时间占比详情
                    _buildTimeDistributionCard(),
                    const SizedBox(height: 16),

                    // 时间浪费预警
                    _buildWasteWarningCard(),
                    const SizedBox(height: 16),

                    // 趋势图
                    _buildTrendChart(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 构建饼图卡片
  Widget _buildPieChartCard() {
    final stats = _selectedPeriod == 0
        ? _getTimeStats(_todayBehaviors)
        : _getTimeStats(_weekBehaviors);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '时间分配',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: stats['total']! == 0
                  ? Center(
                      child: Text(
                        '暂无数据',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: stats['id']!.toDouble(),
                            title: '本我\n${stats['id']}m',
                            color: Colors.red,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats['ego']!.toDouble(),
                            title: '自我\n${stats['ego']}m',
                            color: Colors.teal,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats['superego']!.toDouble(),
                            title: '超我\n${stats['superego']}m',
                            color: Colors.green,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建时间占比详情卡片
  Widget _buildTimeDistributionCard() {
    final stats = _selectedPeriod == 0
        ? _getTimeStats(_todayBehaviors)
        : _getTimeStats(_weekBehaviors);

    final total = stats['total']!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '时间占比详情',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar('本我驱动', stats['id']!, total, Colors.red),
            const SizedBox(height: 12),
            _buildProgressBar('自我驱动', stats['ego']!, total, Colors.teal),
            const SizedBox(height: 12),
            _buildProgressBar('超我驱动', stats['superego']!, total, Colors.green),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('总计时长'),
                Text(
                  '${total ~/ 60}小时${total % 60}分钟',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total == 0 ? 0.0 : value / total;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// 构建时间浪费预警卡片
  Widget _buildWasteWarningCard() {
    final stats = _selectedPeriod == 0
        ? _getTimeStats(_todayBehaviors)
        : _getTimeStats(_weekBehaviors);

    final wasteTime = stats['waste']!;
    final isWasteExceeded = wasteTime > 120;

    return Card(
      color: isWasteExceeded
          ? Colors.red.withOpacity(0.1)
          : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isWasteExceeded ? Icons.warning : Icons.check_circle,
                  color: isWasteExceeded ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  '时间浪费统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isWasteExceeded ? '已超过预警线' : '处于正常范围',
                  style: TextStyle(
                    color: isWasteExceeded ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  '${wasteTime ~/ 60}小时${wasteTime % 60}分钟',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '预警线：2小时/天',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建趋势图
  Widget _buildTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '近7天趋势',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 1),
                        const FlSpot(2, 4),
                        const FlSpot(3, 2),
                        const FlSpot(4, 5),
                        const FlSpot(5, 3),
                        const FlSpot(6, 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
