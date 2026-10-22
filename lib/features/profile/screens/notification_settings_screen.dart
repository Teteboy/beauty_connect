import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/models/notification.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchSettings();
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final settings = provider.settings;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text('PRÉFÉRENCES DE NOTIFICATIONS',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text('Choisissez les notifications que vous souhaitez recevoir',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _settingsCard([
                _settingTile(
                  title: 'Rendez-vous',
                  subtitle: 'Soyez informé des mises à jour de réservation',
                  icon: LucideIcons.calendar,
                  value: settings.bookingNotifications,
                  onChanged: (value) => _updateSetting(
                    settings.copyWith(bookingNotifications: value),
                  ),
                ),
                _settingTile(
                  title: 'Messages',
                  subtitle: 'Soyez informé des nouveaux messages',
                  icon: LucideIcons.messageSquare,
                  value: settings.messageNotifications,
                  onChanged: (value) => _updateSetting(
                    settings.copyWith(messageNotifications: value),
                  ),
                ),
                _settingTile(
                  title: 'Rappels',
                  subtitle: 'Rappels de vos rendez-vous à venir',
                  icon: LucideIcons.alarmClock,
                  value: settings.reminderNotifications,
                  onChanged: (value) => _updateSetting(
                    settings.copyWith(reminderNotifications: value),
                  ),
                ),
                _settingTile(
                  title: 'Conseils et nouveautés',
                  subtitle: 'Recevoir les nouvelles de BeautyConnect',
                  icon: LucideIcons.megaphone,
                  value: settings.marketingNotifications,
                  onChanged: (value) => _updateSetting(
                    settings.copyWith(marketingNotifications: value),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              Text('HISTORIQUE DES NOTIFICATIONS',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              _settingsCard([
                ListTile(
                  leading: const Icon(LucideIcons.listX,
                      color: AppColors.primary),
                  title: const Text('Effacer toutes les notifications'),
                  subtitle: const Text('Supprimer tout l\'historique'),
                  trailing: const Icon(LucideIcons.chevronRight,
                      color: AppColors.textLight),
                  onTap: _showClearNotificationsDialog,
                ),
              ]),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(LucideIcons.circleAlert, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(provider.error!,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ]),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _settingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );

  Future<void> _updateSetting(NotificationSettings newSettings) async {
    final success =
        await context.read<NotificationProvider>().updateSettings(newSettings);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Échec de la mise à jour des paramètres'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _showClearNotificationsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Effacer toutes les notifications'),
        content: const Text(
          'Voulez-vous vraiment effacer tout l\'historique des notifications ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _clearAllNotifications();
            },
            child: const Text('Tout effacer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    final success = await context.read<NotificationProvider>().markAllAsRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? 'Toutes les notifications ont été effacées'
          : 'Échec de l\'effacement des notifications'),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }
}
