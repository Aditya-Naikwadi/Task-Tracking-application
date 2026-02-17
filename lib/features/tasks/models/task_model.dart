enum TaskPriority { high, medium, low }

enum TaskCategory { work, personal, health, social, finance, education, other }

enum TaskStatus { pending, inProgress, completed, overdue }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final TaskCategory category;
  final TaskStatus status;
  final String ownerId;
  final List<String> assignedTo;
  final int totalTimerSeconds; // Target duration
  final int remainingSeconds;
  final bool isTimerRunning;
  final DateTime? lastTimerUpdate;
  final List<String> tags;
  final List<String> attachments;
  final List<Map<String, dynamic>> comments;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.status,
    required this.ownerId,
    this.assignedTo = const [],
    this.totalTimerSeconds = 0,
    this.remainingSeconds = 0,
    this.isTimerRunning = false,
    this.lastTimerUpdate,
    this.tags = const [],
    this.attachments = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'status': status.name,
      'ownerId': ownerId,
      'assignedTo': assignedTo,
      'totalTimerSeconds': totalTimerSeconds,
      'remainingSeconds': remainingSeconds,
      'isTimerRunning': isTimerRunning,
      'lastTimerUpdate': lastTimerUpdate?.toIso8601String(),
      'tags': tags,
      'attachments': attachments,
      'comments': comments,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      priority: TaskPriority.values.byName(map['priority']),
      category: TaskCategory.values.byName(map['category']),
      status: TaskStatus.values.byName(map['status']),
      ownerId: map['ownerId'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      totalTimerSeconds: map['totalTimerSeconds'] ?? 0,
      remainingSeconds: map['remainingSeconds'] ?? 0,
      isTimerRunning: map['isTimerRunning'] ?? false,
      lastTimerUpdate: map['lastTimerUpdate'] != null
          ? DateTime.parse(map['lastTimerUpdate'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      attachments: List<String>.from(map['attachments'] ?? []),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    TaskCategory? category,
    TaskStatus? status,
    int? remainingSeconds,
    bool? isTimerRunning,
    DateTime? lastTimerUpdate,
    List<String>? tags,
    List<String>? attachments,
    List<Map<String, dynamic>>? comments,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      ownerId: ownerId,
      assignedTo: assignedTo,
      totalTimerSeconds: totalTimerSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      lastTimerUpdate: lastTimerUpdate ?? this.lastTimerUpdate,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
    );
  }
}
