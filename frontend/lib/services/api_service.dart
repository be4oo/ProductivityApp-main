import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Token expired, redirect to login
            _clearToken();
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Authentication
  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/token', data: {
        'username': username,
        'password': password,
      });
      
      final token = response.data['access_token'];
      await _saveToken(token);
      return token;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> register(String email, String username, String password, [String? fullName]) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      });
      
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Projects
  Future<List<Project>> getProjects() async {
    try {
      final response = await _dio.get('/projects/');
      return (response.data as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  Future<Project> createProject(String name, [String? description, String color = '#909dab']) async {
    try {
      final response = await _dio.post('/projects/', data: {
        'name': name,
        'description': description,
        'color': color,
      });
      return Project.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<Project> updateProject(int id, {String? name, String? description, String? color}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (color != null) data['color'] = color;
      
      final response = await _dio.put('/projects/$id', data: data);
      return Project.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _dio.delete('/projects/$id');
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // Tasks
  Future<List<Task>> getTasks([int? projectId]) async {
    try {
      final response = await _dio.get('/tasks/', queryParameters: {
        if (projectId != null) 'project_id': projectId,
      });
      return (response.data as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<Task> createTask({
    required String title,
    String? notes,
    String? description,
    String column = 'Backlog',
    int estimatedTime = 0,
    String? taskType,
    String? taskPriority,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    int? estimatedPomodoros,
    DateTime? dueDate,
    bool reminderEnabled = false,
    int reminderOffset = 0,
    required int projectId,
  }) async {
    try {
      final response = await _dio.post('/tasks/', data: {
        'title': title,
        'notes': notes,
        'description': description,
        'column': column,
        'estimated_time': estimatedTime,
        'task_type': taskType,
        'task_priority': taskPriority,
        'priority': priority?.index,
        'status': status?.index,
        'tags': tags,
        'estimated_pomodoros': estimatedPomodoros,
        'due_date': dueDate?.toIso8601String(),
        'reminder_enabled': reminderEnabled,
        'reminder_offset': reminderOffset,
        'project_id': projectId,
      });
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(int id, {
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
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (notes != null) data['notes'] = notes;
      if (description != null) data['description'] = description;
      if (column != null) data['column'] = column;
      if (estimatedTime != null) data['estimated_time'] = estimatedTime;
      if (actualTime != null) data['actual_time'] = actualTime;
      if (taskType != null) data['task_type'] = taskType;
      if (taskPriority != null) data['task_priority'] = taskPriority;
      if (priority != null) data['priority'] = priority.index;
      if (status != null) data['status'] = status.index;
      if (tags != null) data['tags'] = tags;
      if (estimatedPomodoros != null) data['estimated_pomodoros'] = estimatedPomodoros;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String();
      if (reminderEnabled != null) data['reminder_enabled'] = reminderEnabled;
      if (reminderOffset != null) data['reminder_offset'] = reminderOffset;
      if (isUrgent != null) data['is_urgent'] = isUrgent;
      if (isImportant != null) data['is_important'] = isImportant;
      
      final response = await _dio.put('/tasks/$id', data: data);
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<Task> moveTask(int id, String column) async {
    try {
      final response = await _dio.put('/tasks/$id/move', queryParameters: {
        'column': column,
      });
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to move task: $e');
    }
  }

  Future<Task> updateTaskMatrix(int id, bool isUrgent, bool isImportant) async {
    try {
      final response = await _dio.put('/tasks/$id/matrix', queryParameters: {
        'is_urgent': isUrgent,
        'is_important': isImportant,
      });
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update task matrix: $e');
    }
  }

  // Dashboard
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }
}
