import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/behavior.dart';

/// 添加行为记录对话框
class AddBehaviorDialog extends StatefulWidget {
  final DateTime date;

  const AddBehaviorDialog({super.key, required this.date});

  @override
  State<AddBehaviorDialog> createState() => _AddBehaviorDialogState();
}

class _AddBehaviorDialogState extends State<AddBehaviorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _timePeriod = '上午';
  int _duration = 30;
  String _driveType = 'ego';
  int _emotion = 3;
  bool _isWaste = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// 保存记录
  void _save() {
    if (_formKey.currentState!.validate()) {
      final behavior = Behavior(
        date: DateFormat('yyyy-MM-dd').format(widget.date),
        timePeriod: _timePeriod,
        description: _descriptionController.text,
        duration: _duration,
        driveType: _driveType,
        emotion: _emotion,
        isWaste: _isWaste,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      Navigator.pop(context, behavior);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加行为记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 行为描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '行为描述',
                  hintText: '例如：刷抖音、学习编程、锻炼身体',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行为描述';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 时间段选择
              const Text('时间段', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '上午', label: Text('上午')),
                  ButtonSegment(value: '下午', label: Text('下午')),
                  ButtonSegment(value: '晚上', label: Text('晚上')),
                ],
                selected: {_timePeriod},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _timePeriod = selection.first);
                },
              ),
              const SizedBox(height: 16),

              // 持续时长
              Row(
                children: [
                  const Text('持续时长', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('$_duration 分钟', style: const TextStyle(fontSize: 16)),
                ],
              ),
              Slider(
                value: _duration.toDouble(),
                min: 5,
                max: 240,
                divisions: 47,
                label: '$_duration 分钟',
                onChanged: (value) {
                  setState(() => _duration = value.round());
                },
              ),
              const SizedBox(height: 8),

              // 心理驱动类型
              const Text('心理驱动类型', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDriveTypeSelector(),
              const SizedBox(height: 16),

              // 情绪状态
              Row(
                children: [
                  const Text('情绪状态', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _emotion ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() => _emotion = index + 1);
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 是否浪费时间
              SwitchListTile(
                title: const Text('是否浪费时间'),
                subtitle: Text(
                  _isWaste ? '这是无意义的时间消耗' : '这是有意义的时间投入',
                  style: TextStyle(
                    color: _isWaste ? Colors.red : Colors.green,
                  ),
                ),
                value: _isWaste,
                onChanged: (value) {
                  setState(() => _isWaste = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }

  /// 构建驱动类型选择器
  Widget _buildDriveTypeSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.red),
              SizedBox(width: 8),
              Text('本我驱动'),
            ],
          ),
          subtitle: const Text('欲望、冲动、即时满足（如刷手机、吃零食）'),
          value: 'id',
          groupValue: _driveType,
          onChanged: (value) {
            setState(() => _driveType = value!);
          },
        ),
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.balance, color: Colors.teal),
              SizedBox(width: 8),
              Text('自我驱动'),
            ],
          ),
          subtitle: const Text('理性、现实考量、平衡（如工作、学习、社交）'),
          value: 'ego',
          groupValue: _driveType,
          onChanged: (value) {
            setState(() => _driveType = value!);
          },
        ),
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.green),
              SizedBox(width: 8),
              Text('超我驱动'),
            ],
          ),
          subtitle: const Text('道德、理想、自律（如锻炼、帮助他人、学习提升）'),
          value: 'superego',
          groupValue: _driveType,
          onChanged: (value) {
            setState(() => _driveType = value!);
          },
        ),
      ],
    );
  }
}
