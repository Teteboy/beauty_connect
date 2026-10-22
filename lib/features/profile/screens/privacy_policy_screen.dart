import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/profile'),
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MON ESPACE · COMPTE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Confidentialité',
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
                ],
              ),
              const SizedBox(height: 12),

              // Trust banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.navyBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votre confiance compte',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gardez le contrôle sur votre compte et les informations que vous partagez.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMedium,
                                      height: 1.4,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _SectionTitle('Sécurité du compte'),
              _NavRow(
                title: 'Changer le mot de passe',
                subtitle: 'Dernière modification : récemment',
                onTap: () => context.go('/change-password'),
              ),

              const SizedBox(height: 16),
              _SectionTitle('Préférences de notifications'),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final settings = provider.settings;
                  return Column(
                    children: [
                      _ToggleRow(
                        title: 'Rendez-vous et messages',
                        subtitle: 'Informations liées à votre activité.',
                        value: settings.bookingNotifications ||
                            settings.messageNotifications,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(
                            bookingNotifications: value,
                            messageNotifications: value,
                          ),
                        ),
                      ),
                      _ToggleRow(
                        title: 'Conseils et nouveautés',
                        subtitle: 'Recevoir les nouvelles de BeautyConnect.',
                        value: settings.marketingNotifications,
                        onChanged: (value) => provider.updateSettings(
                          settings.copyWith(marketingNotifications: value),
                        ),
                      ),
                    ],
                  );
                },
              ),
              _NavRow(
                title: 'Autorisations de l\'appareil',
                subtitle: 'Photos, caméra et notifications',
                onTap: () => context.go('/notification-settings'),
              ),

              const SizedBox(height: 16),
              _SectionTitle('Mes données personnelles'),
              _NavRow(
                title: 'Télécharger mes données',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export de vos données — bientôt disponible'),
                  ),
                ),
              ),
              _NavRow(
                title: 'Politique de confidentialité',
                onTap: () => _showPolicySheet(context),
              ),
              _NavRow(
                title: 'Supprimer mon compte',
                subtitle: 'Une confirmation sera nécessaire.',
                isDestructive: true,
                trailing: const Icon(LucideIcons.trash,
                    color: AppColors.error, size: 20),
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Politique de confidentialité',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Dernière mise à jour : ${DateTime.now().year}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              const _PolicySection(
                title: '1. Informations collectées',
                content:
                    'Nous collectons les informations que vous nous fournissez : création de compte, réservations, échanges avec les prestataires, avis et évaluations. Cela peut inclure votre nom, e-mail, téléphone, localisation et photos de profil.',
              ),
              const _PolicySection(
                title: '2. Utilisation de vos informations',
                content:
                    'Vos données servent à fournir et améliorer nos services : traitement des réservations, communication sur votre compte, assistance et respect de nos obligations légales.',
              ),
              const _PolicySection(
                title: '3. Partage des informations',
                content:
                    'Nous partageons vos informations uniquement avec les prestataires pour faciliter vos rendez-vous, avec nos prestataires techniques, ou lorsque la loi l\'exige. Nous ne vendons jamais vos données personnelles.',
              ),
              const _PolicySection(
                title: '4. Sécurité et conservation',
                content:
                    'Nous appliquons des mesures de sécurité appropriées et conservons vos données uniquement le temps nécessaire à la fourniture de nos services.',
              ),
              const _PolicySection(
                title: '5. Vos droits',
                content:
                    'Vous pouvez accéder à vos données, les modifier, supprimer votre compte ou refuser les communications marketing. Contactez-nous à privacy@beautyconnect.com pour exercer ces droits.',
              ),
              const _PolicySection(
                title: '6. Nous contacter',
                content:
                    'Pour toute question sur cette politique : privacy@beautyconnect.com. Nous répondons sous 30 jours.',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'La suppression de votre compte est définitive. Pour confirmer, contactez notre équipe à support@beautyconnect.com.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Compris', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NavRow({
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textDark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMedium,
                                  ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    const Icon(LucideIcons.chevronRight,
                        color: AppColors.textDark, size: 22),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMedium,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final bool isLast;

  const _PolicySection({
    required this.title,
    required this.content,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
