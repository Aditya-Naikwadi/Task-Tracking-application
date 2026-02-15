import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class CategoryDistributionChart extends StatelessWidget {
  const CategoryDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    
    if (tasks.isEmpty) return const SizedBox.shrink();

    // Group tasks by category
    final Map<TaskCategory, int> distribution = {};
    for (var task in tasks) {
      distribution[task.category] = (distribution[task.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: distribution.entries.map((entry) {
                  return PieChartSectionData(
                    color: _getCategoryColor(entry.key),
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: distribution.keys.map((cat) => _buildLegend(cat)).toList(),
        ),
      ],
    );
  }

  Widget _buildLegend(TaskCategory category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _getCategoryColor(category)),
        ),
        const SizedBox(width: 4),
        Text(category.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
      ],
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work: return AppColors.teal;
      case TaskCategory.personal: return AppColors.orange;
      case TaskCategory.health: return const Color(0xFFFF5252);
      case TaskCategory.finance: return const Color(0xFFFFD740);
      case TaskCategory.education: return const Color(0xFF7C4DFF);
      case TaskCategory.other: return AppColors.textGrey;
      default: return AppColors.teal;
    }
  }
}
