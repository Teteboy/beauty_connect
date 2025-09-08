import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize() async {
    try {
      await ApiService.loadToken();
      if (ApiService.hasToken) {
        await getCurrentUser();
      }
    } catch (e) {
      // Silently handle initialization errors
      _user = null;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response['token'] != null && response['user'] != null) {
        await ApiService.setToken(response['token']);
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid response from server';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? location,
    String? bio,
    String? specialty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
        'location': location,
        'bio': bio,
        'specialty': specialty,
      });

      if (response['success']) {
        final token = response['token'];
        final userData = response['user'];
        
        await ApiService.setToken(token);
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      if (!ApiService.hasToken) {
        return false;
      }
      await getCurrentUser();
      return _user != null;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await ApiService.get('/auth/me');
      _user = User.fromJson(response);
      _isAuthenticated = true; // Add this line
      notifyListeners();
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.clearToken();
    } catch (e) {
      // Continue with logout even if token clearing fails
    } finally {
      _user = null;
      _isAuthenticated = false; // Add this line
      _clearError();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await ApiService.put('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    if (email.trim().isEmpty) {
      _error = 'Email is required';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      await ApiService.post('/auth/forgot-password', {
        'email': email.trim(),
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (token.trim().isEmpty || newPassword.trim().isEmpty) {
      _error = 'Token and password are required';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      final response = await ApiService.post('/auth/reset-password', {
        'token': token.trim(),
        'password': newPassword,
      });
      
      // Auto-login after successful password reset
      if (response['token'] != null) {
        await ApiService.setToken(response['token']);
        await getCurrentUser();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    
    try {
      await ApiService.delete('/auth/account');
      await logout();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('Invalid credentials')) {
        return 'Invalid email or password';
      } else if (errorString.contains('User already exists')) {
        return 'An account with this email already exists';
      } else if (errorString.contains('Network error')) {
        return 'Network connection failed. Please check your internet connection.';
      } else if (errorString.contains('Token expired')) {
        return 'Your session has expired. Please login again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Role-based getters
  bool get isCustomer => _user?.role == 'customer';
  bool get isTechnician => _user?.role == 'technician';
  bool get isAdmin => _user?.role == 'admin';

  // Additional utility getters
  String? get userRole => _user?.role;
  String? get userName => _user != null ? '${_user!.firstName} ${_user!.lastName}' : null;
  String? get userEmail => _user?.email;

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? location,
    String? bio,
    String? specialty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.put('/auth/profile', {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
        if (bio != null) 'bio': bio,
        if (specialty != null) 'specialty': specialty,
      });

      if (response['success']) {
        _user = User.fromJson(response['user']);
        return true;
      } else {
        _error = response['message'] ?? 'Profile update failed';
        return false;
      }
    } catch (e) {
      _error = 'Profile update failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}






