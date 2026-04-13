import 'package:flutter/material.dart';
import '../models/behavior.dart';

/// 行为记录卡片组件
class BehaviorCard extends StatelessWidget {
  final Behavior behavior;
  final VoidCallback onDelete;

  const BehaviorCard({
    super.key,
    required this.behavior,
    required this.onDelete,
  });

  Color _getDriveColor() {
    switch (behavior.driveType) {
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

  IconData _getTimePeriodIcon() {
    switch (behavior.timePeriod) {
      case '上午':
        return Icons.wb_sunny;
      case '下午':
        return Icons.wb_twilight;
      case '晚上':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetails(context),
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：时间段和驱动类型
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDriveColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTimePeriodIcon(),
                          size: 16,
                          color: _getDriveColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          behavior.timePeriod,
                          style: TextStyle(
                            color: _getDriveColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDriveColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      behavior.driveTypeName,
                      style: TextStyle(
                        color: _getDriveColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (behavior.isWaste)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '浪费时间',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 行为描述
              Text(
                behavior.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              
              // 底部：时长和情绪
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${behavior.duration}分钟',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${behavior.emotion}星',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示详情对话框
  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('时间段', behavior.timePeriod),
            _buildDetailRow('行为描述', behavior.description),
            _buildDetailRow('持续时长', '${behavior.duration}分钟'),
            _buildDetailRow('驱动类型', behavior.driveTypeName),
            _buildDetailRow('情绪状态', '${behavior.emotion}星'),
            _buildDetailRow('是否浪费时间', behavior.isWaste ? '是' : '否'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(
              '删除',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
