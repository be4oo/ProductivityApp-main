import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class PersistentProjectProvider with ChangeNotifier {
  Box<Project>? _projectBox;
  Box<int>? _projectMetadataBox;
  List<Project> _projects = [];
  int _nextProjectId = 1;
  int? _selectedProjectId;
  bool _isInitialized = false;
  String? _initializationError;

  List<Project> get projects => _projects;
  int? get selectedProjectId => _selectedProjectId;
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

      // Register adapters if not already registered
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

      final boxAlreadyExists = await Hive.boxExists('projects');
      _projectBox = await _openStorageBox<Project>('projects');
      _projectMetadataBox = await _openStorageBox<int>('project_metadata');
      _loadProjects();
      final savedNextId = _projectMetadataBox!.get('next_id') ?? 1;
      if (savedNextId > _nextProjectId) _nextProjectId = savedNextId;
      // Existing installs keep all entity IDs; only the next-ID counter is new.
      await _projectMetadataBox!.put('next_id', _nextProjectId);
      _isInitialized = true;

      // Seed only a new store; an intentionally empty store must stay empty.
      if (!boxAlreadyExists && _projects.isEmpty) {
        await _addSampleProjects();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing PersistentProjectProvider: $e');
      _isInitialized = false;
      _initializationError =
          'Project storage could not be opened. Please restart the app to try again.';
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

  void _loadProjects() {
    _projects = _projectBox!.values.toList();
    if (_projects.isNotEmpty) {
      final nextId =
          _projects.map((value) => value.id).reduce((a, b) => a > b ? a : b) +
              1;
      if (nextId > _nextProjectId) _nextProjectId = nextId;
    }
  }

  Future<void> _addSampleProjects() async {
    final sampleProjects = [
      Project(
        id: _nextProjectId++,
        name: 'Personal Tasks',
        description: 'Personal productivity and life management',
        color: 'blue',
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: _nextProjectId++,
        name: 'Web Development',
        description: 'Frontend and backend development projects',
        color: 'green',
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: _nextProjectId++,
        name: 'Mobile App',
        description: 'Flutter mobile application development',
        color: 'purple',
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: _nextProjectId++,
        name: 'Research & Learning',
        description: 'Educational content and research projects',
        color: 'orange',
        ownerId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await _projectMetadataBox!.put('next_id', _nextProjectId);
    for (final project in sampleProjects) {
      await _saveProject(project);
    }
  }

  Future<void> _saveProject(Project project) async {
    if (!_isInitialized) throw StateError('Project storage is unavailable');
    // Do not acknowledge a change until its durable write has succeeded.
    await _projectBox!.put(project.id, project);
    final index = _projects.indexWhere((value) => value.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }
  }

  Future<void> createProject(Project project) async {
    if (!_isInitialized) throw StateError('Project storage is unavailable');
    final id = _nextProjectId++;
    // Persist the reservation first. A failed record write may leave a gap,
    // but deleted IDs must never be reused after a restart.
    await _projectMetadataBox!.put('next_id', _nextProjectId);
    final newProject = Project(
      id: id,
      name: project.name,
      description: project.description,
      color: project.color,
      ownerId: project.ownerId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveProject(newProject);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final updatedProject = Project(
      id: project.id,
      name: project.name,
      description: project.description,
      color: project.color,
      ownerId: project.ownerId,
      createdAt: project.createdAt,
      updatedAt: DateTime.now(),
    );

    await _saveProject(updatedProject);
    notifyListeners();
  }

  Future<void> deleteProject(int projectId) async {
    if (!_isInitialized) throw StateError('Project storage is unavailable');
    await _projectBox!.delete(projectId);
    _projects.removeWhere((project) => project.id == projectId);
    if (_selectedProjectId == projectId) {
      _selectedProjectId = null;
    }
    notifyListeners();
  }

  void selectProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Project? getProjectById(int projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  String getProjectName(int projectId) {
    final project = getProjectById(projectId);
    return project?.name ?? 'Unknown Project';
  }

  Color getProjectColor(int projectId) {
    final project = getProjectById(projectId);
    if (project == null) return Colors.grey;

    final color = project.color.trim();
    if (color.startsWith('#')) {
      final hex = color.substring(1);
      final value = int.tryParse(hex, radix: 16);
      if (value != null && (hex.length == 6 || hex.length == 8)) {
        return Color(hex.length == 6 ? value | 0xFF000000 : value);
      }
    }
    switch (color.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  bool get isLoading => false;

  Future<void> loadProjects() async {
    if (_isInitialized) {
      _loadProjects();
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _projectBox?.close();
    } catch (e) {
      debugPrint('Error closing project box: $e');
    }
    try {
      await _projectMetadataBox?.close();
    } catch (e) {
      debugPrint('Error closing project metadata box: $e');
    }
    super.dispose();
  }
}
