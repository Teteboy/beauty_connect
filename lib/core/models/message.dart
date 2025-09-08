import 'user.dart';

class Message {
  final dynamic id; // Changed from int to dynamic to handle UUID strings
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime timestamp;
  final User? sender;
  final User? receiver;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.timestamp,
    this.sender,
    this.receiver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        id: json['id'], // Keep as dynamic since backend uses UUID
        senderId: _parseId(json['senderId']),
        receiverId: _parseId(json['receiverId']),
        content: json['content'],
        isRead: json['isRead'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
        sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
        receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing Message JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.parse(id);
    throw ArgumentError('Invalid ID type: ${id.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}






