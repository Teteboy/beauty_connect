import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  NotificationSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/notifications');
      if (response['success']) {
        _notifications = (response['data'] as List)
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to fetch notifications';
      }
    } catch (e) {
      _error = 'Failed to fetch notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/notifications/settings');
      if (response['success']) {
        _settings = NotificationSettings.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Failed to fetch notification settings';
      }
    } catch (e) {
      _error = 'Failed to fetch notification settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(NotificationSettings newSettings) async {
    try {
      final response =
          await ApiService.put('/notifications/settings', newSettings.toJson());

      if (response['success']) {
        _settings = NotificationSettings.fromJson(response['data']);
        notifyListeners();
        return true;
      } else {
        _error =
            response['message'] ?? 'Failed to update notification settings';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update notification settings: $e';
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response =
          await ApiService.put('/notifications/$notificationId/read', {});

      if (response['success']) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to mark notification as read';
        return false;
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await ApiService.put('/notifications/mark-all-read', {});

      if (response['success']) {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        notifyListeners();
        return true;
      } else {
        _error =
            response['message'] ?? 'Failed to mark all notifications as read';
        return false;
      }
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response =
          await ApiService.delete('/notifications/$notificationId');

      if (response['success']) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete notification';
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
