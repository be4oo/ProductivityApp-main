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
