// Task Priority Enum
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

// Task Status Enum  
enum TaskStatus {
  todo,
  inProgress,
  done,
  completed,
  cancelled,
}

// Project Priority Enum
enum ProjectPriority {
  low,
  medium,
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

class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final bool isActive;
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

class Project {
  final int id;
  final String name;
  final String? description;
  final String color;
  final int ownerId;
  final DateTime createdAt;
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

class Task {
  final int id;
  final String title;
  final String? notes;
  final String? description;
  final String column;
  final int estimatedTime;
  final int actualTime;
  final String? taskType;
  final String? taskPriority;
  final TaskPriority priority;
  final TaskStatus status;
  final List<String>? tags;
  final int? estimatedPomodoros;
  final DateTime? dueDate;
  final bool reminderEnabled;
  final int reminderOffset;
  final bool isUrgent;
  final bool isImportant;
  final int projectId;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
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
