import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Message> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  List<Message> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/messages/conversation/$userId');
      if (response['success']) {
        _messages = (response['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load messages';
      }
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/messages/conversations');
      if (response['success']) {
        _conversations = (response['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load conversations';
      }
    } catch (e) {
      _error = 'Failed to load conversations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final response = await ApiService.post('/messages', {
        'receiverId': int.parse(receiverId),
        'content': content,
      });

      if (response['success']) {
        final newMessage = Message.fromJson(response['data']);
        _messages.add(newMessage);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to send message';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
