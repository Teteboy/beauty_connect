import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/messages/conversations');
      print('Conversations response: $response');

      if (response is List) {
        _conversations = response
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Parsed ${_conversations.length} conversations');
      } else {
        _error = 'Invalid response format';
        _conversations = [];
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      _error = 'Failed to fetch conversations: $e';
      _conversations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/messages/conversations/$userId');
      print('Messages response: $response');

      if (response is List) {
        _messages = response
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Parsed ${_messages.length} messages');
      } else {
        _error = 'Invalid response format';
        _messages = [];
      }
    } catch (e) {
      print('Error fetching messages: $e');
      _error = 'Failed to fetch messages: $e';
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    _error = null;

    try {
      final response = await ApiService.post('/messages', {
        'receiverId': receiverId,
        'content': content,
      });

      if (response is Map<String, dynamic>) {
        final newMessage = Message.fromJson(response);
        _messages.add(newMessage);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending message: $e');
      _error = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(String messageId) async {
    try {
      await ApiService.put('/messages/$messageId/read', {});

      // Update local message
      final messageIndex =
          _messages.indexWhere((m) => m.id.toString() == messageId);
      if (messageIndex != -1) {
        final updatedMessage = Message(
          id: _messages[messageIndex].id,
          senderId: _messages[messageIndex].senderId,
          receiverId: _messages[messageIndex].receiverId,
          content: _messages[messageIndex].content,
          isRead: true,
          timestamp: _messages[messageIndex].timestamp,
          sender: _messages[messageIndex].sender,
          receiver: _messages[messageIndex].receiver,
          createdAt: _messages[messageIndex].createdAt,
          updatedAt: DateTime.now(),
        );
        _messages[messageIndex] = updatedMessage;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
