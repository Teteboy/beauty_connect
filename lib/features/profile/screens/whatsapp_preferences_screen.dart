import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

/// Écran « Notifications WhatsApp » (mon compte).
///
/// Aucun endpoint backend n'existe pour ces préférences : tout est persisté
/// localement via [StorageHelper] (SharedPreferences). Quand un endpoint
/// `/notification-preferences/whatsapp` existera, brancher [_save] dessus.
class WhatsappPreferencesScreen extends StatefulWidget {
  const WhatsappPreferencesScreen({super.key});

  @override
  State<WhatsappPreferencesScreen> createState() =>
      _WhatsappPreferencesScreenState();
}

class _WhatsappPreferencesScreenState extends State<WhatsappPreferencesScreen> {
  static const String _numberKey = 'whatsapp_number';
  static const String _transactionalKey = 'whatsapp_transactional';
  static const String _remindersKey = 'whatsapp_reminders';
  static const String _messagesKey = 'whatsapp_messages';
  static const String _marketingKey = 'whatsapp_marketing';

  final TextEditingController _numberController = TextEditingController();
  bool _transactional = true;
  bool _reminders = true;
  bool _messages = true;
  bool _marketing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _numberController.text =
        await StorageHelper.getString(_numberKey) ?? '+237 ';
    _transactional = await StorageHelper.getBool(_transactionalKey) ?? true;
    _reminders = await StorageHelper.getBool(_remindersKey) ?? true;
    _messages = await StorageHelper.getBool(_messagesKey) ?? true;
    _marketing = await StorageHelper.getBool(_marketingKey) ?? false;
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await StorageHelper.saveString(_numberKey, _numberController.text);
      await StorageHelper.saveBool(_transactionalKey, _transactional);
      await StorageHelper.saveBool(_remindersKey, _reminders);
      await StorageHelper.saveBool(_messagesKey, _messages);
      await StorageHelper.saveBool(_marketingKey, _marketing);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préférences enregistrées'),
          backgroundColor: AppColors.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _revoke() async {
    setState(() {
      _transactional = false;
      _reminders = false;
      _messages = false;
      _marketing = false;
    });
    await _save();
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
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mon compte / Notifications'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  'Notifications WhatsApp',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.orangePale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.info,
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connecteur en cours de configuration',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Aucun message WhatsApp n\'est envoyé pour le moment. Vos notifications dans l\'app restent disponibles.',
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _numberController,
                  label: 'Numéro WhatsApp',
                  hintText: '+237 6 99 41 20 30',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(LucideIcons.smartphone,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                _toggleCard(
                  title: 'Messages transactionnels',
                  subtitle:
                      'Confirmations, rappels, annulations et reçus liés à vos réservations.',
                  value: _transactional,
                  onChanged: (v) => setState(() => _transactional = v),
                ),
                _toggleCard(
                  title: 'Rappels de rendez-vous',
                  subtitle:
                      'Recevez un rappel WhatsApp avant chaque réservation confirmée.',
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                ),
                _toggleCard(
                  title: 'Messages',
                  subtitle:
                      'Soyez informé des nouveaux messages reçus dans l\'app.',
                  value: _messages,
                  onChanged: (v) => setState(() => _messages = v),
                ),
                _toggleCard(
                  title: 'Offres & actualités',
                  subtitle:
                      'Promotions et recommandations marketing. Facultatif, désactivé par défaut.',
                  value: _marketing,
                  onChanged: (v) => setState(() => _marketing = v),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choix indépendants. Un numéro vérifié ne vaut pas consentement. Votre accord sera requis avant tout envoi après activation.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Révoquer les consentements',
                  isDestructive: true,
                  onPressed: _revoke,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.bell,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Votre historique reste dans l\'app',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'La révocation bloque les futurs envois WhatsApp ; elle ne supprime pas vos notifications internes.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => context.push('/notification-settings'),
                        child: const Text(
                          'Consulter mes notifications →',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: CustomButton(
              text: 'Enregistrer mes préférences',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
        ),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
