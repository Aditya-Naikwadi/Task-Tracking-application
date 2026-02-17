import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../tasks/providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/widgets/create_task_dialog.dart';
import '../../tasks/screens/task_detail_screen.dart';
import '../../../core/widgets/app_logo.dart';
import '../widgets/productivity_chart.dart';
import '../widgets/category_distribution_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.uid;
      if (userId != null) {
        Provider.of<TaskProvider>(context, listen: false).init(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: AppLogo(size: 40, showText: false),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.teal,
              child: Text(
                authProvider.userData?.fullName[0].toUpperCase() ??
                    authProvider.user?.email?[0].toUpperCase() ??
                    'U',
                style: const TextStyle(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  authProvider.userData?.fullName ??
                      authProvider.user?.email?.split('@')[0] ??
                      'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // XP Bar
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textGrey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (authProvider.userData?.xp ?? 0) % 500 / 500,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lvl ${authProvider.userData?.level ?? 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildStreakBadge(authProvider.userData?.streak ?? 0),
          IconButton(
            onPressed: () => authProvider.logout(),
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    taskProvider.pendingTasks.length.toString(),
                    AppColors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Done',
                    taskProvider.completedTasks.length.toString(),
                    AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const ProductivityChart(),
            const SizedBox(height: 24),
            const CategoryDistributionChart(),
            const SizedBox(height: 32),
            const Text(
              'Your Tasks',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Task List
            Expanded(
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskProvider.tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        return FadeInLeft(
                          delay: Duration(milliseconds: index * 100),
                          child: _buildTaskTile(task, taskProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateTaskDialog(),
          );
        },
        backgroundColor: AppColors.teal,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(TaskModel task, TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: task.status == TaskStatus.completed,
                activeColor: AppColors.teal,
                onChanged: (_) async {
                  final xpEarned = await provider.toggleTaskStatus(task);
                  if (xpEarned > 0) {
                    if (mounted) {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).addXP(xpEarned);
                    }
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.completed
                            ? AppColors.textGrey
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(task.deadline),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getPriorityIcon(task.priority),
                color: _getPriorityColor(task.priority),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department,
          color: AppColors.orange,
          size: 20,
        ),
        Text(
          '$streak',
          style: const TextStyle(
            color: AppColors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textGrey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet. Start being productive!',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.orange;
      case TaskPriority.low:
        return AppColors.teal;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.trending_up;
      case TaskPriority.low:
        return Icons.trending_flat;
    }
  }
}
