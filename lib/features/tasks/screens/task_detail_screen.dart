import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Timer? _ticker;
  late int _displaySeconds;

  @override
  void initState() {
    super.initState();
    _displaySeconds = widget.task.remainingSeconds;
    if (widget.task.isTimerRunning) {
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_displaySeconds > 0) {
        setState(() => _displaySeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    // Find the latest task state from provider if it exists
    final currentTask = taskProvider.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () {
              taskProvider.deleteTask(currentTask.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Category Badges
            Row(
              children: [
                _buildBadge(
                  currentTask.category.name.toUpperCase(),
                  AppColors.teal,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  currentTask.priority.name.toUpperCase(),
                  _getPriorityColor(currentTask.priority),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              currentTask.title,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              currentTask.description.isEmpty
                  ? 'No description provided.'
                  : currentTask.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Timer Card
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Focus Timer',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatDuration(_displaySeconds),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimerButton(
                        icon: currentTask.isTimerRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                        label: currentTask.isTimerRunning ? 'PAUSE' : 'START',
                        color: AppColors.teal,
                        onPressed: () {
                          if (currentTask.isTimerRunning) {
                            taskProvider.stopTimer(currentTask);
                            _ticker?.cancel();
                          } else {
                            taskProvider.startTimer(currentTask);
                            _startTicker();
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      _TimerButton(
                        icon: Icons.refresh,
                        label: 'RESET',
                        color: AppColors.textGrey,
                        onPressed: () {
                          // Reset logic can be added to TaskProvider
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Collaboration & Details
            _buildInfoTile(
              Icons.calendar_today,
              'Deadline',
              DateFormat(
                'MMMM dd, yyyy - hh:mm a',
              ).format(currentTask.deadline),
            ),
            _buildInfoTile(
              Icons.person_outline,
              'Assigned to',
              currentTask.assignedTo.isEmpty
                  ? 'Only me'
                  : currentTask.assignedTo.join(', '),
            ),
            _buildInfoTile(
              Icons.label_outline,
              'Tags',
              currentTask.tags.isEmpty
                  ? 'No tags'
                  : currentTask.tags.join(', '),
            ),

            const SizedBox(height: 24),
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (currentTask.attachments.isNotEmpty)
              _buildAttachmentList(currentTask.attachments),
            _buildAttachmentButton(taskProvider, currentTask.id),

            const SizedBox(height: 24),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (currentTask.comments.isNotEmpty)
              _buildCommentList(currentTask.comments),
            _buildCommentPlaceHolder(
              authProvider.user?.email ?? 'Unknown',
              taskProvider,
              currentTask.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentList(List<String> attachments) {
    return Column(
      children: attachments
          .map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.file_present,
                    color: AppColors.teal,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      url.split('/').last,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final _commentController = TextEditingController();

  void _sendComment(String userId, TaskProvider provider, String taskId) {
    if (_commentController.text.trim().isEmpty) return;
    provider.addComment(taskId, userId, _commentController.text.trim());
    _commentController.clear();
  }

  Widget _buildCommentPlaceHolder(
    String userId,
    TaskProvider provider,
    String taskId,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.textGrey),
              ),
              onSubmitted: (_) => _sendComment(userId, provider, taskId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.teal),
            onPressed: () => _sendComment(userId, provider, taskId),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(List<Map<String, dynamic>> comments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.teal,
                child: Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['userId'].split('@')[0], // Simple display name
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                    Text(
                      comment['content'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentButton(TaskProvider provider, String taskId) {
    return InkWell(
      onTap: () {}, // This could be implemented with a file picker
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.teal, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Attachment',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
