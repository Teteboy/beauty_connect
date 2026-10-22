import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/notification.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  void _markAllAsRead() async {
    await context.read<NotificationProvider>().markAllAsRead();
  }

  void _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      await context.read<NotificationProvider>().markAsRead(notification.id);
    }

    if (notification.relatedId != null) {
      switch (notification.type) {
        case 'booking':
          context.go('/booking-detail/${notification.relatedId}');
          break;
        case 'message':
          context.go('/chat/${notification.relatedId}');
          break;
        case 'service':
          context.go('/service/${notification.relatedId}');
          break;
        default:
          break;
      }
    }
  }

  void _deleteNotification(String notificationId) async {
    await context
        .read<NotificationProvider>()
        .deleteNotification(notificationId);
  }

  Map<String, List<AppNotification>> _groupNotifications(
      List<AppNotification> notifications) {
    final today = <AppNotification>[];
    final thisWeek = <AppNotification>[];
    final older = <AppNotification>[];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));

    for (final n in notifications) {
      if (n.createdAt.isAfter(todayStart)) {
        today.add(n);
      } else if (n.createdAt.isAfter(weekStart)) {
        thisWeek.add(n);
      } else {
        older.add(n);
      }
    }

    return {
      'Aujourd\'hui': today,
      'Cette semaine': thisWeek,
      'Plus ancien': older,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.textDark),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MON ESPACE · CLIENT',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Notifications',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) {
                      if (provider.unreadCount <= 0) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        onPressed: _markAllAsRead,
                        tooltip: 'Tout marquer comme lu',
                        icon: const Icon(Icons.done_all,
                            color: AppColors.primary),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.unreadCount <= 0) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: _markAllAsRead,
                    child: Text(
                      'Tout marquer comme lu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (provider.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vos notifications apparaîtront ici',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final groups = _groupNotifications(provider.notifications);

                  return ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      ..._buildGroup('Aujourd\'hui', groups['Aujourd\'hui']!),
                      ..._buildGroup('Cette semaine', groups['Cette semaine']!),
                      ..._buildGroup('Plus ancien', groups['Plus ancien']!),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                color:
                                    AppColors.textLight.withValues(alpha: 0.5),
                                size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'FIN DES NOTIFICATIONS',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.textLight
                                        .withValues(alpha: 0.6),
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroup(String title, List<AppNotification> notifications) {
    if (notifications.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      ...notifications.map(
        (notification) => _NotificationCard(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onDismiss: () => _deleteNotification(notification.id),
        ),
      ),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'payment':
        return Icons.credit_card;
      case 'review':
        return Icons.star_outline;
      case 'service':
        return Icons.spa;
      case 'offer':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? const Border(
                  left: BorderSide(color: AppColors.accent, width: 3),
                )
              : Border.all(color: AppColors.divider),
          boxShadow: AppColors.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.orangePale,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconForType(notification.type),
                      color: AppColors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notification.timeAgo,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMedium,
                                    height: 1.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
