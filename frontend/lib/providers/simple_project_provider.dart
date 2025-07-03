import 'package:flutter/material.dart';
import '../models/models.dart';

class SimpleProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  int _nextProjectId = 1;
  
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  
  SimpleProjectProvider() {
    // Create a default project
    final defaultProject = Project(
      id: _nextProjectId++,
      name: 'Personal',
      description: 'Personal tasks and projects',
      color: '#6366F1',
      ownerId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _projects.add(defaultProject);
    _selectedProject = defaultProject;
  }
  
  Future<void> createProject(String name, [String? description, String color = '#909dab']) async {
    final project = Project(
      id: _nextProjectId++,
      name: name,
      description: description,
      color: color,
      ownerId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _projects.add(project);
    _selectedProject = project;
    notifyListeners();
  }
  
  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }
  
  Future<void> updateProject(int id, {String? name, String? description, String? color}) async {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      final project = _projects[index];
      _projects[index] = Project(
        id: project.id,
        name: name ?? project.name,
        description: description ?? project.description,
        color: color ?? project.color,
        ownerId: project.ownerId,
        createdAt: project.createdAt,
        updatedAt: DateTime.now(),
      );
      
      if (_selectedProject?.id == id) {
        _selectedProject = _projects[index];
      }
      
      notifyListeners();
    }
  }
  
  void deleteProject(int id) {
    _projects.removeWhere((p) => p.id == id);
    
    if (_selectedProject?.id == id) {
      _selectedProject = _projects.isNotEmpty ? _projects.first : null;
    }
    
    notifyListeners();
  }
  
  bool get isLoading => false;
  
  Future<void> loadProjects() async {
    // No-op for local storage
  }
}
