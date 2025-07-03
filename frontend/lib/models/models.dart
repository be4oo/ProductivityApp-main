import 'package:hive/hive.dart';

part 'models.g.dart';

// Task Priority Enum
@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

// Task Status Enum  
@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled,
}

// Project Priority Enum
@HiveType(typeId: 2)
enum ProjectPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

// Extensions for better display
extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension ProjectPriorityExtension on ProjectPriority {
  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
    }
  }
}

@HiveType(typeId: 3)
class User {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String? fullName;
  @HiveField(4)
  final bool isActive;
  @HiveField(5)
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 4)
class Project {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String color;
  @HiveField(4)
  final int ownerId;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 5)
class Task {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? notes;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String column;
  @HiveField(5)
  final int estimatedTime;
  @HiveField(6)
  final int actualTime;
  @HiveField(7)
  final String? taskType;
  @HiveField(8)
  final String? taskPriority;
  @HiveField(9)
  final TaskPriority priority;
  @HiveField(10)
  final TaskStatus status;
  @HiveField(11)
  final List<String>? tags;
  @HiveField(12)
  final int? estimatedPomodoros;
  @HiveField(13)
  final DateTime? dueDate;
  @HiveField(14)
  final bool reminderEnabled;
  @HiveField(15)
  final int reminderOffset;
  @HiveField(16)
  final bool isUrgent;
  @HiveField(17)
  final bool isImportant;
  @HiveField(18)
  final int projectId;
  @HiveField(19)
  final int ownerId;
  @HiveField(20)
  final DateTime createdAt;
  @HiveField(21)
  final DateTime updatedAt;
  @HiveField(22)
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.notes,
    this.description,
    required this.column,
    required this.estimatedTime,
    required this.actualTime,
    this.taskType,
    this.taskPriority,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.tags,
    this.estimatedPomodoros,
    this.dueDate,
    required this.reminderEnabled,
    required this.reminderOffset,
    required this.isUrgent,
    required this.isImportant,
    required this.projectId,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      description: json['description'],
      column: json['column'],
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'],
      taskType: json['task_type'],
      taskPriority: json['task_priority'],
      priority: TaskPriority.values[json['priority'] ?? 1],
      status: TaskStatus.values[json['status'] ?? 0],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      estimatedPomodoros: json['estimated_pomodoros'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      reminderEnabled: json['reminder_enabled'],
      reminderOffset: json['reminder_offset'],
      isUrgent: json['is_urgent'],
      isImportant: json['is_important'],
      projectId: json['project_id'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'description': description,
      'column': column,
      'estimated_time': estimatedTime,
      'actual_time': actualTime,
      'task_type': taskType,
      'task_priority': taskPriority,
      'priority': priority.index,
      'status': status.index,
      'tags': tags,
      'estimated_pomodoros': estimatedPomodoros,
      'due_date': dueDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled,
      'reminder_offset': reminderOffset,
      'is_urgent': isUrgent,
      'is_important': isImportant,
      'project_id': projectId,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? notes,
    String? description,
    String? column,
    int? estimatedTime,
    int? actualTime,
    String? taskType,
    String? taskPriority,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    int? estimatedPomodoros,
    DateTime? dueDate,
    bool? reminderEnabled,
    int? reminderOffset,
    bool? isUrgent,
    bool? isImportant,
    int? projectId,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      column: column ?? this.column,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      taskType: taskType ?? this.taskType,
      taskPriority: taskPriority ?? this.taskPriority,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      dueDate: dueDate ?? this.dueDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      projectId: projectId ?? this.projectId,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods for better UI display
  String get estimatedTimeDisplay {
    if (estimatedPomodoros != null && estimatedPomodoros! > 0) {
      return '${estimatedPomodoros}🍅 (~${estimatedTime}min)';
    }
    if (estimatedTime > 0) {
      final hours = estimatedTime ~/ 60;
      final minutes = estimatedTime % 60;
      if (hours > 0) {
        return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
      }
      return '${minutes}min';
    }
    return 'Not estimated';
  }

  String get actualTimeDisplay {
    if (actualTime > 0) {
      final hours = actualTime ~/ 60;
      final minutes = actualTime % 60;
      if (hours > 0) {
        return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
      }
      return '${minutes}min';
    }
    return 'No time logged';
  }

  String get progressDisplay {
    if (estimatedTime > 0) {
      final percentage = (actualTime / estimatedTime * 100).clamp(0, 100);
      return '${percentage.toStringAsFixed(0)}%';
    }
    return actualTime > 0 ? 'Time logged' : 'No progress';
  }

  bool get isOverdue {
    return dueDate != null && dueDate!.isBefore(DateTime.now()) && status != TaskStatus.completed;
  }

  String get dueDateDisplay {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dueDate!.month}/${dueDate!.day}';
    }
  }
}

class DashboardStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int todayTasks;
  final int thisWeekTasks;
  final double completionRate;

  DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.todayTasks,
    required this.thisWeekTasks,
    required this.completionRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTasks: json['total_tasks'],
      completedTasks: json['completed_tasks'],
      pendingTasks: json['pending_tasks'],
      overdueTasks: json['overdue_tasks'],
      todayTasks: json['today_tasks'],
      thisWeekTasks: json['this_week_tasks'],
      completionRate: json['completion_rate'].toDouble(),
    );
  }
}
