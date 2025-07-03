import 'package:flutter/material.dart';
import '../models/models.dart';

class SimpleTaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  int _nextTaskId = 1;
  
  List<Task> get tasks => _tasks;
  
  SimpleTaskProvider() {
    // Add some sample tasks for testing
    _addSampleTasks();
  }
  
  void _addSampleTasks() {
    // Sample tasks for project 1 (Personal)
    _tasks.addAll([
      Task(
        id: _nextTaskId++,
        title: 'Review project requirements',
        description: 'Go through all the project requirements and make notes',
        column: 'Backlog',
        estimatedTime: 50,
        actualTime: 0,
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: true,
        isImportant: true,
        projectId: 1,
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['planning', 'urgent'],
        estimatedPomodoros: 2,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Update documentation',
        description: 'Update the project documentation with latest changes',
        column: 'In Progress',
        estimatedTime: 75,
        actualTime: 25,
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        reminderEnabled: true,
        reminderOffset: 30,
        isUrgent: false,
        isImportant: true,
        projectId: 1,
        ownerId: 1,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now(),
        tags: ['documentation'],
        estimatedPomodoros: 3,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Fix minor UI bugs',
        description: 'Address the small UI inconsistencies reported by users',
        column: 'To Do',
        estimatedTime: 25,
        actualTime: 0,
        priority: TaskPriority.low,
        status: TaskStatus.todo,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: true,
        isImportant: false,
        projectId: 1,
        ownerId: 1,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        updatedAt: DateTime.now(),
        tags: ['bug', 'ui'],
        estimatedPomodoros: 1,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Prepare presentation',
        description: 'Create slides for the upcoming team meeting',
        column: 'Done',
        estimatedTime: 100,
        actualTime: 95,
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: false,
        isImportant: false,
        projectId: 1,
        ownerId: 1,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now(),
        completedAt: DateTime.now().subtract(Duration(hours: 1)),
        tags: ['presentation'],
        estimatedPomodoros: 4,
      ),
    ]);
  }
  
  void createTask({
    required String title,
    String? description,
    required int projectId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String>? tags,
    int estimatedPomodoros = 1,
  }) {
    final task = Task(
      id: _nextTaskId++,
      title: title,
      description: description,
      column: 'Backlog',
      estimatedTime: estimatedPomodoros * 25,
      actualTime: 0,
      priority: priority,
      status: TaskStatus.todo,
      reminderEnabled: false,
      reminderOffset: 0,
      isUrgent: false,
      isImportant: false,
      projectId: projectId,
      ownerId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
      estimatedPomodoros: estimatedPomodoros,
    );
    
    _tasks.add(task);
    notifyListeners();
  }
  
  void deleteTask(int id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
  
  void updateTask(int id, {
    String? title, 
    String? description,
    TaskStatus? status,
    String? column,
    TaskPriority? priority,
    bool? isUrgent,
    bool? isImportant,
    DateTime? dueDate,
    List<String>? tags,
    int? estimatedPomodoros,
  }) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = Task(
        id: task.id,
        title: title ?? task.title,
        description: description ?? task.description,
        column: column ?? task.column,
        estimatedTime: estimatedPomodoros != null ? estimatedPomodoros * 25 : task.estimatedTime,
        actualTime: task.actualTime,
        priority: priority ?? task.priority,
        status: status ?? task.status,
        reminderEnabled: task.reminderEnabled,
        reminderOffset: task.reminderOffset,
        isUrgent: isUrgent ?? task.isUrgent,
        isImportant: isImportant ?? task.isImportant,
        projectId: task.projectId,
        ownerId: task.ownerId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: status == TaskStatus.completed ? DateTime.now() : task.completedAt,
        dueDate: dueDate ?? task.dueDate,
        tags: tags ?? task.tags,
        estimatedPomodoros: estimatedPomodoros ?? task.estimatedPomodoros,
      );
      notifyListeners();
    }
  }
  
  List<Task> getTasksByColumn(String column) {
    return _tasks.where((task) => task.column == column).toList();
  }
  
  List<Task> getTasksByProject(int projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }
  
  List<Task> getTasksByColumnAndProject(String column, int projectId) {
    return _tasks.where((task) => task.column == column && task.projectId == projectId).toList();
  }
  
  List<Task> getTasksForMatrix() {
    return _tasks.toList();
  }
  
  List<Task> getTasksForMatrixByProject(int projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }
  
  void moveTaskToColumn(int taskId, String newColumn) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        column: newColumn,
        estimatedTime: task.estimatedTime,
        actualTime: task.actualTime,
        priority: task.priority,
        status: newColumn == 'Done' ? TaskStatus.completed : TaskStatus.todo,
        reminderEnabled: task.reminderEnabled,
        reminderOffset: task.reminderOffset,
        isUrgent: task.isUrgent,
        isImportant: task.isImportant,
        projectId: task.projectId,
        ownerId: task.ownerId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: newColumn == 'Done' ? DateTime.now() : task.completedAt,
        dueDate: task.dueDate,
        tags: task.tags,
      );
      notifyListeners();
    }
  }
  
  void updateTaskUrgencyImportance(int taskId, bool isUrgent, bool isImportant) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        column: task.column,
        estimatedTime: task.estimatedTime,
        actualTime: task.actualTime,
        priority: task.priority,
        status: task.status,
        reminderEnabled: task.reminderEnabled,
        reminderOffset: task.reminderOffset,
        isUrgent: isUrgent,
        isImportant: isImportant,
        projectId: task.projectId,
        ownerId: task.ownerId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: task.completedAt,
        dueDate: task.dueDate,
        tags: task.tags,
      );
      notifyListeners();
    }
  }
  
  DashboardStats? get dashboardStats {
    if (_tasks.isEmpty) return null;
    
    final completedTasks = _tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalTasks = _tasks.length;
    final pendingTasks = totalTasks - completedTasks;
    final overdueTasks = _tasks.where((t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.completed).length;
    final todayTasks = _tasks.where((t) => 
        t.createdAt.day == DateTime.now().day &&
        t.createdAt.month == DateTime.now().month &&
        t.createdAt.year == DateTime.now().year).length;
    final thisWeekTasks = _tasks.where((t) => 
        t.createdAt.isAfter(DateTime.now().subtract(Duration(days: 7)))).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
    
    return DashboardStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      todayTasks: todayTasks,
      thisWeekTasks: thisWeekTasks,
      completionRate: completionRate,
    );
  }

  bool get isLoading => false;
  
  Future<void> loadTasks() async {
    // No-op for local storage
  }
  
  Future<void> loadDashboardStats() async {
    // No-op for local storage
  }
}
