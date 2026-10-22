import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppNotification {
  final String id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? relatedId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      userId: json['userId'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      relatedId: json['relatedId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'relatedId': relatedId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  IconData get icon {
    switch (type) {
      case 'booking':
        return LucideIcons.calendar;
      case 'message':
        return LucideIcons.messageSquare;
      case 'payment':
        return LucideIcons.creditCard;
      case 'review':
        return LucideIcons.star;
      case 'service':
        return LucideIcons.flower;
      default:
        return LucideIcons.bell;
    }
  }

  Color get color {
    switch (type) {
      case 'booking':
        return Colors.blue;
      case 'message':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'review':
        return Colors.amber;
      case 'service':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  AppNotification copyWith({
    String? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? relatedId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettings {
  final bool bookingNotifications;
  final bool messageNotifications;
  final bool reminderNotifications;
  final bool marketingNotifications;

  NotificationSettings({
    this.bookingNotifications = true,
    this.messageNotifications = true,
    this.reminderNotifications = true,
    this.marketingNotifications = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      bookingNotifications: json['bookingNotifications'] ?? true,
      messageNotifications: json['messageNotifications'] ?? true,
      reminderNotifications: json['reminderNotifications'] ?? true,
      marketingNotifications: json['marketingNotifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingNotifications': bookingNotifications,
      'messageNotifications': messageNotifications,
      'reminderNotifications': reminderNotifications,
      'marketingNotifications': marketingNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? bookingNotifications,
    bool? messageNotifications,
    bool? reminderNotifications,
    bool? marketingNotifications,
  }) {
    return NotificationSettings(
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      marketingNotifications:
          marketingNotifications ?? this.marketingNotifications,
    );
  }
}
