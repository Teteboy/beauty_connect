import 'user.dart';
import 'message.dart';

class Conversation {
  final User user;
  final Message? lastMessage;
  final int unreadCount;

  Conversation({
    required this.user,
    this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      user: User.fromJson(json['user']),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }

  String get conversationId => user.id.toString();

  DateTime? get lastMessageTime => lastMessage?.timestamp;

  String? get lastMessageContent => lastMessage?.content;

  bool get isOnline => false;
}
