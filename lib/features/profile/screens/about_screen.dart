import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/utils/navigation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('À propos'),
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? safePop(context, fallback: '/profile') : context.go('/profile'),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 120, circular: false),
                  const SizedBox(height: 16),
                  Text(
                    'Beauty Connect',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            Text(
              'À propos de BeautyConnect',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: _cardDecoration,
              padding: const EdgeInsets.all(20),
              child: Text(
                'BeautyConnect est votre plateforme de référence pour découvrir et réserver des services de beauté. Nous connectons les clients avec des prestataires talentueux, pour trouver plus facilement le service idéal.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
              ),
            ),

            const SizedBox(height: 24),

            // Features Section
            Text(
              'Fonctionnalités',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: _cardDecoration,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _FeatureItem(
                    icon: LucideIcons.search,
                    title: 'Découvrir des services',
                    description:
                        'Parcourez et recherchez des services de beauté près de chez vous',
                  ),
                  _FeatureItem(
                    icon: LucideIcons.calendar,
                    title: 'Réservation facile',
                    description: 'Réservez en quelques touches',
                  ),
                  _FeatureItem(
                    icon: LucideIcons.messageCircle,
                    title: 'Communication directe',
                    description: 'Discutez directement avec les prestataires',
                  ),
                  _FeatureItem(
                    icon: LucideIcons.star,
                    title: 'Avis et évaluations',
                    description: 'Lisez les avis et notez vos expériences',
                  ),
                  _FeatureItem(
                    icon: LucideIcons.creditCard,
                    title: 'Paiements sécurisés',
                    description: 'Un traitement des paiements sûr et sécurisé',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Section
            Container(
              decoration: _cardDecoration,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nous contacter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _ContactItem(
                    icon: LucideIcons.mail,
                    title: 'Email',
                    value: 'support@beautyconnect.com',
                    onTap: () => _launchEmail('support@beautyconnect.com'),
                  ),
                  _ContactItem(
                    icon: LucideIcons.phone,
                    title: 'Téléphone',
                    value: '+1 (555) 123-4567',
                    onTap: () => _launchPhone('+15551234567'),
                  ),
                  _ContactItem(
                    icon: LucideIcons.globe,
                    title: 'Site web',
                    value: 'www.beautyconnect.com',
                    onTap: () =>
                        _launchWebsite('https://www.beautyconnect.com'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Legal Section
            Container(
              decoration: _cardDecoration,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentions légales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(LucideIcons.fileText,
                        color: AppColors.primaryLight),
                    title: const Text('Conditions d\'utilisation',
                        style: TextStyle(color: AppColors.textDark)),
                    trailing: const Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColors.textLight),
                    onTap: () => context.go('/terms'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.shieldCheck,
                        color: AppColors.primaryLight),
                    title: const Text('Politique de confidentialité',
                        style: TextStyle(color: AppColors.textDark)),
                    trailing: const Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColors.textLight),
                    onTap: () => context.go('/privacy'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading:
                        const Icon(LucideIcons.gavel, color: AppColors.primaryLight),
                    title: const Text('Licences',
                        style: TextStyle(color: AppColors.textDark)),
                    trailing: const Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColors.textLight),
                    onTap: () => _showLicensePage(context),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Copyright
            Center(
              child: Text(
                '© 2024 BeautyConnect. Tous droits réservés.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWebsite(String url) async {
    final Uri webUri = Uri.parse(url);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Beauty Connect',
      applicationVersion: '1.0.0',
      applicationIcon: const AppLogo(size: 50, circular: false),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryLight),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(LucideIcons.externalLink, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
