import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/models/notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = notificationProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose which notifications you want to receive',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSettingTile(
                        title: 'Booking Notifications',
                        subtitle: 'Get notified about booking updates',
                        icon: Icons.calendar_today,
                        value: settings.bookingNotifications,
                        onChanged: (value) => _updateSetting(
                          settings.copyWith(bookingNotifications: value),
                        ),
                      ),
                      
                      _buildSettingTile(
                        title: 'Message Notifications',
                        subtitle: 'Get notified about new messages',
                        icon: Icons.message,
                        value: settings.messageNotifications,
                        onChanged: (value) => _updateSetting(
                          settings.copyWith(messageNotifications: value),
                        ),
                      ),
                      
                      _buildSettingTile(
                        title: 'Reminder Notifications',
                        subtitle: 'Get reminded about upcoming appointments',
                        icon: Icons.alarm,
                        value: settings.reminderNotifications,
                        onChanged: (value) => _updateSetting(
                          settings.copyWith(reminderNotifications: value),
                        ),
                      ),
                      
                      _buildSettingTile(
                        title: 'Marketing Notifications',
                        subtitle: 'Get notified about promotions and offers',
                        icon: Icons.campaign,
                        value: settings.marketingNotifications,
                        onChanged: (value) => _updateSetting(
                          settings.copyWith(marketingNotifications: value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        leading: const Icon(Icons.clear_all),
                        title: const Text('Clear All Notifications'),
                        subtitle: const Text('Remove all notification history'),
                        onTap: _showClearNotificationsDialog,
                      ),
                    ],
                  ),
                ),
              ),

              if (notificationProvider.error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            notificationProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _updateSetting(NotificationSettings newSettings) async {
    final success = await context.read<NotificationProvider>().updateSettings(newSettings);
    
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update notification settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notification history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllNotifications();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() async {
    final success = await context.read<NotificationProvider>().markAllAsRead();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'All notifications cleared' 
                : 'Failed to clear notifications',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}



