import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class PersistentProjectProvider with ChangeNotifier {
  late Box<Project> _projectBox;
  List<Project> _projects = [];
  int _nextProjectId = 1;
  int? _selectedProjectId;
  bool _isInitialized = false;
  
  List<Project> get projects => _projects;
  int? get selectedProjectId => _selectedProjectId;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
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
      
      _projectBox = await Hive.openBox<Project>('projects');
      _loadProjects();
      
      // Add sample projects if the box is empty
      if (_projects.isEmpty) {
        await _addSampleProjects();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing PersistentProjectProvider: $e');
      // Fallback to in-memory storage
      await _addSampleProjects();
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _loadProjects() {
    _projects = _projectBox.values.toList();
    if (_projects.isNotEmpty) {
      _nextProjectId = _projects.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
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

    for (final project in sampleProjects) {
      await _saveProject(project);
    }
  }

  Future<void> _saveProject(Project project) async {
    try {
      if (_isInitialized) {
        await _projectBox.put(project.id, project);
      }
      
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        _projects[index] = project;
      } else {
        _projects.add(project);
      }
    } catch (e) {
      print('Error saving project: $e');
      // Fallback to in-memory storage
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        _projects[index] = project;
      } else {
        _projects.add(project);
      }
    }
  }

  Future<void> createProject(Project project) async {
    final newProject = Project(
      id: _nextProjectId++,
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
    try {
      if (_isInitialized) {
        await _projectBox.delete(projectId);
      }
      _projects.removeWhere((project) => project.id == projectId);
      
      // Clear selection if the deleted project was selected
      if (_selectedProjectId == projectId) {
        _selectedProjectId = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error deleting project: $e');
      _projects.removeWhere((project) => project.id == projectId);
      
      if (_selectedProjectId == projectId) {
        _selectedProjectId = null;
      }
      
      notifyListeners();
    }
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
    
    switch (project.color.toLowerCase()) {
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

  Future<void> dispose() async {
    try {
      await _projectBox.close();
    } catch (e) {
      print('Error closing project box: $e');
    }
    super.dispose();
  }
}
