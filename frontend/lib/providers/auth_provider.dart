import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  
  AuthProvider() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      
      // In development mode, start as unauthenticated
      // so users can see the login screen
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = null;
      
      // Try to get user if backend is available
      // final user = await _apiService.getCurrentUser();
      // _user = user;
      // _status = AuthStatus.authenticated;
      // _errorMessage = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = null;
    }
    notifyListeners();
  }
  
  Future<bool> login(String username, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Development mode: Allow any username/password
      if (username.isNotEmpty && password.isNotEmpty) {
        // Create a dummy user for development
        _user = User(
          id: 1,
          email: '$username@demo.com',
          username: username,
          fullName: username,
          isActive: true,
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      
      // If backend is available, try real authentication
      await _apiService.login(username, password);
      final user = await _apiService.getCurrentUser();
      
      _user = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      
      return true;
    } catch (e) {
      // If backend fails, still allow login in development
      if (username.isNotEmpty && password.isNotEmpty) {
        _user = User(
          id: 1,
          email: '$username@demo.com',
          username: username,
          fullName: username,
          isActive: true,
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = e.toString();
      notifyListeners();
      
      return false;
    }
  }
  
  Future<bool> register(String email, String username, String password, [String? fullName]) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      await _apiService.register(email, username, password, fullName);
      
      // Auto-login after registration
      final success = await login(username, password);
      return success;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = e.toString();
      notifyListeners();
      
      return false;
    }
  }
  
  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
