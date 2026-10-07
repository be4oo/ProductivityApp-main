import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class PersistentTaskProvider with ChangeNotifier {
  Box<Task>? _taskBox;
  Box<int>? _taskMetadataBox;
  List<Task> _tasks = [];
  int _nextTaskId = 1;
  bool _isInitialized = false;
  String? _initializationError;

  List<Task> get tasks => _tasks;
  bool get isInitialized => _isInitialized;
  String? get initializationError => _initializationError;

  Future<void> initialize({String? storagePath}) async {
    if (_isInitialized) return;
    _initializationError = null;

    try {
      if (storagePath == null) {
        await Hive.initFlutter();
      } else {
        Hive.init(storagePath);
      }

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskPriorityAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TaskStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ProjectPriorityAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(UserAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(ProjectAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(TaskAdapter());
      }

      final boxAlreadyExists = await Hive.boxExists('tasks');
      _taskBox = await _openStorageBox<Task>('tasks');
      _taskMetadataBox = await _openStorageBox<int>('task_metadata');
      _loadTasks();
      final savedNextId = _taskMetadataBox!.get('next_id') ?? 1;
      if (savedNextId > _nextTaskId) _nextTaskId = savedNextId;
      // Existing installs keep all entity IDs; only the next-ID counter is new.
      await _taskMetadataBox!.put('next_id', _nextTaskId);
      _isInitialized = true;

      // Seed only a new store; an intentionally empty store must stay empty.
      if (!boxAlreadyExists && _tasks.isEmpty) {
        await _addSampleTasks();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing PersistentTaskProvider: $e');
      _isInitialized = false;
      _initializationError =
          'Task storage could not be opened. Please restart the app to try again.';
      notifyListeners();
    }
  }

  Future<Box<T>> _openStorageBox<T>(String name) async {
    // Hive 2.x also completes a shared opening future on failure. A second
    // observer handles that future, preventing an uncaught duplicate error
    // while still reporting the original open failure to initialize().
    final opening = Hive.openBox<T>(name);
    final sharedOpening = Hive.openBox<T>(name);
    return (await Future.wait([opening, sharedOpening])).first;
  }

  void _loadTasks() {
    _tasks = _taskBox!.values.toList();
    if (_tasks.isNotEmpty) {
      final nextId =
          _tasks.map((value) => value.id).reduce((a, b) => a > b ? a : b) + 1;
      if (nextId > _nextTaskId) _nextTaskId = nextId;
    }
  }

  Future<void> _addSampleTasks() async {
    final sampleTasks = [
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['documentation'],
        estimatedPomodoros: 3,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Fix responsive layout bug',
        description:
            'The mobile layout is not working correctly on small screens',
        column: 'To Do',
        estimatedTime: 120,
        actualTime: 0,
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: true,
        isImportant: false,
        projectId: 2,
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['bug', 'frontend'],
        estimatedPomodoros: 5,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Research new UI library',
        description:
            'Look into modern UI libraries for better component design',
        column: 'Backlog',
        estimatedTime: 180,
        actualTime: 30,
        priority: TaskPriority.low,
        status: TaskStatus.todo,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: false,
        isImportant: false,
        projectId: 2,
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['research', 'ui'],
        estimatedPomodoros: 7,
      ),
      Task(
        id: _nextTaskId++,
        title: 'Database optimization',
        description: 'Optimize database queries for better performance',
        column: 'Done',
        estimatedTime: 90,
        actualTime: 85,
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        reminderEnabled: false,
        reminderOffset: 0,
        isUrgent: false,
        isImportant: true,
        projectId: 3,
        ownerId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['backend', 'optimization'],
        estimatedPomodoros: 4,
      ),
    ];

    await _taskMetadataBox!.put('next_id', _nextTaskId);
    for (final task in sampleTasks) {
      await _saveTask(task);
    }
  }

  Future<void> _saveTask(Task task) async {
    if (!_isInitialized) throw StateError('Task storage is unavailable');
    // Do not acknowledge a change until its durable write has succeeded.
    await _taskBox!.put(task.id, task);
    final index = _tasks.indexWhere((value) => value.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  Future<void> createTask(Task task) async {
    if (!_isInitialized) throw StateError('Task storage is unavailable');
    final id = _nextTaskId++;
    // Persist the reservation first. A failed record write may leave a gap,
    // but deleted IDs must never be reused after a restart.
    await _taskMetadataBox!.put('next_id', _nextTaskId);
    final newTask = task.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveTask(newTask);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _saveTask(updatedTask);
    notifyListeners();
  }

  Future<void> deleteTask(int taskId) async {
    if (!_isInitialized) throw StateError('Task storage is unavailable');
    await _taskBox!.delete(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(int taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final isCompleted =
        task.status == TaskStatus.completed || task.status == TaskStatus.done;

    final updatedTask = task.copyWith(
      status: isCompleted ? TaskStatus.todo : TaskStatus.completed,
      completedAt: isCompleted ? null : DateTime.now(),
      clearCompletedAt: isCompleted,
      column: isCompleted ? 'To Do' : 'Done',
      updatedAt: DateTime.now(),
    );

    // Completion must be durable before the UI acknowledges success.
    if (!_isInitialized) throw StateError('Task storage is unavailable');
    await _taskBox!.put(taskId, updatedTask);
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index >= 0) _tasks[index] = updatedTask;
    notifyListeners();
  }

  List<Task> getTasksByColumn(String column) {
    return _tasks.where((task) => task.column == column).toList();
  }

  List<Task> getTasksByProject(int projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<void> moveTaskToColumn(int taskId, String newColumn) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final status = newColumn == 'Done'
        ? TaskStatus.completed
        : newColumn == 'In Progress'
            ? TaskStatus.inProgress
            : TaskStatus.todo;

    final updatedTask = task.copyWith(
      column: newColumn,
      status: status,
      completedAt: newColumn == 'Done' ? DateTime.now() : null,
      clearCompletedAt: newColumn != 'Done',
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }

  Future<void> updateTaskUrgencyImportance(
      int taskId, bool isUrgent, bool isImportant) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(
      isUrgent: isUrgent,
      isImportant: isImportant,
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }

  DashboardStats? get dashboardStats {
    if (_tasks.isEmpty) return null;

    final completedTasks =
        _tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalTasks = _tasks.length;
    final pendingTasks = totalTasks - completedTasks;
    final overdueTasks = _tasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.isBefore(DateTime.now()) &&
            t.status != TaskStatus.completed)
        .length;
    final todayTasks = _tasks
        .where((t) =>
            t.createdAt.day == DateTime.now().day &&
            t.createdAt.month == DateTime.now().month &&
            t.createdAt.year == DateTime.now().year)
        .length;
    final thisWeekTasks = _tasks
        .where((t) => t.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

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
    if (_isInitialized) {
      _loadTasks();
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    // Stats are computed on-demand
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    try {
      await _taskBox?.close();
    } catch (e) {
      debugPrint('Error closing task box: $e');
    }
    try {
      await _taskMetadataBox?.close();
    } catch (e) {
      debugPrint('Error closing task metadata box: $e');
    }
    super.dispose();
  }
}
