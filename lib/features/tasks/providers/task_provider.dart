import 'package:flutter/material.dart';
import 'dart:io';
import '../../../services/task_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/storage_service.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Filtered Tasks
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.status != TaskStatus.completed).toList();
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();

  void init(String userId) {
    _isLoading = true;
    _repository.getUnifiedTasksStream(userId).listen((newTasks) {
      _tasks = newTasks;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _repository.createTask(task);

    // Schedule notification for 5 minutes before deadline
    final scheduleTime = task.deadline.subtract(const Duration(minutes: 5));
    if (scheduleTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: scheduleTime,
      );
    }
  }

  Future<int> toggleTaskStatus(TaskModel task) async {
    final isCompleting = task.status != TaskStatus.completed;
    final newStatus = isCompleting ? TaskStatus.completed : TaskStatus.pending;

    await _repository.updateTask(task.copyWith(status: newStatus));

    if (isCompleting) {
      // Award XP based on priority
      switch (task.priority) {
        case TaskPriority.high:
          return 50;
        case TaskPriority.medium:
          return 30;
        case TaskPriority.low:
          return 10;
      }
    }
    return 0;
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
  }

  // Add Comment
  Future<void> addComment(String taskId, String userId, String content) async {
    final comment = {
      'userId': userId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _repository.addComment(taskId, comment);
  }

  // Upload and Add Attachment
  Future<void> uploadAttachment(String taskId, File file) async {
    final url = await StorageService().uploadTaskAttachment(taskId, file);
    if (url != null) {
      await _repository.addAttachment(taskId, url);
    }
  }

  // Timer Logic
  void startTimer(TaskModel task) async {
    final updatedTask = task.copyWith(
      isTimerRunning: true,
      lastTimerUpdate: DateTime.now(),
    );
    await _repository.updateTask(updatedTask);
  }

  void stopTimer(TaskModel task) async {
    final now = DateTime.now();
    int spent = 0;
    if (task.lastTimerUpdate != null) {
      spent = now.difference(task.lastTimerUpdate!).inSeconds;
    }

    final updatedTask = task.copyWith(
      isTimerRunning: false,
      remainingSeconds: (task.remainingSeconds - spent).clamp(
        0,
        task.totalTimerSeconds,
      ),
      lastTimerUpdate: null,
    );
    await _repository.updateTask(updatedTask);
  }

  // Update remaining seconds for active timers (e.g. on dashboard open)
  void syncTimers() {
    bool changed = false;
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isTimerRunning && _tasks[i].lastTimerUpdate != null) {
        final now = DateTime.now();
        final elapsed = now.difference(_tasks[i].lastTimerUpdate!).inSeconds;
        _tasks[i] = _tasks[i].copyWith(
          remainingSeconds: (_tasks[i].remainingSeconds - elapsed).clamp(
            0,
            _tasks[i].totalTimerSeconds,
          ),
          lastTimerUpdate: now,
        );
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
