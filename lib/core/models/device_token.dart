class DeviceToken {
  final int id;
  final int userId;
  final String token;
  final String platform;
  final bool isActive;
  final DateTime lastUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    required this.isActive,
    required this.lastUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      id: json['id'],
      userId: json['userId'],
      token: json['token'],
      platform: json['platform'],
      isActive: json['isActive'] ?? true,
      lastUsed: DateTime.parse(json['lastUsed']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'token': token,
      'platform': platform,
      'isActive': isActive,
      'lastUsed': lastUsed.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isIOS => platform.toLowerCase() == 'ios';
  bool get isAndroid => platform.toLowerCase() == 'android';
  bool get isWeb => platform.toLowerCase() == 'web';

  DeviceToken copyWith({
    int? id,
    int? userId,
    String? token,
    String? platform,
    bool? isActive,
    DateTime? lastUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceToken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      isActive: isActive ?? this.isActive,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettings {
  final int id;
  final int userId;
  final bool bookingNotifications;
  final bool messageNotifications;
  final bool reminderNotifications;
  final bool marketingNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettings({
    required this.id,
    required this.userId,
    required this.bookingNotifications,
    required this.messageNotifications,
    required this.reminderNotifications,
    required this.marketingNotifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'],
      userId: json['userId'],
      bookingNotifications: json['bookingNotifications'] ?? true,
      messageNotifications: json['messageNotifications'] ?? true,
      reminderNotifications: json['reminderNotifications'] ?? true,
      marketingNotifications: json['marketingNotifications'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookingNotifications': bookingNotifications,
      'messageNotifications': messageNotifications,
      'reminderNotifications': reminderNotifications,
      'marketingNotifications': marketingNotifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationSettings copyWith({
    int? id,
    int? userId,
    bool? bookingNotifications,
    bool? messageNotifications,
    bool? reminderNotifications,
    bool? marketingNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
