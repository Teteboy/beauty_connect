import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        leading: IconButton(
          onPressed: () => safePop(context, fallback: '/profile'),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dernière mise à jour : ${DateTime.now().year}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            const _TermsSection(
              title: '1. Objet du service',
              content:
                  'BeautyConnect est une plateforme de mise en relation entre des clients et des prestataires de services de beauté au Cameroun. Elle permet la découverte de professionnels, la prise de rendez-vous, la messagerie et le paiement de frais de réservation.',
            ),
            const _TermsSection(
              title: '2. Comptes et rôles',
              content:
                  'Les clients peuvent réserver des services ; les prestataires proposent leurs services, gèrent leur agenda et leurs disponibilités. Vous êtes responsable de la confidentialité de vos identifiants et des informations fournies.',
            ),
            const _TermsSection(
              title: '3. Réservations et frais',
              content:
                  'Toute réservation peut être soumise à des frais de réservation (500 XAF) affichés avant confirmation. Le prestataire peut accepter ou refuser une demande. Les annulations et reprogrammations respectent les règles affichées dans l\'application.',
            ),
            const _TermsSection(
              title: '4. Contenus et avis',
              content:
                  'Les avis doivent être honnêtes et respectueux. BeautyConnect peut modérer tout contenu trompeur, offensant ou contraire à la loi. Les prestataires garantissent l\'exactitude de leur catalogue et de leurs tarifs.',
            ),
            const _TermsSection(
              title: '5. Responsabilité',
              content:
                  'BeautyConnect agit comme intermédiaire et n\'est pas partie au contrat de service entre le client et le prestataire. La plateforme ne saurait être tenue responsable de la qualité des prestations réalisées.',
            ),
            const _TermsSection(
              title: '6. Suspension et résiliation',
              content:
                  'Un compte peut être suspendu en cas d\'abus, de fraude ou de non-respect de ces conditions. Vous pouvez demander la suppression de votre compte à support@beautyconnect.com.',
            ),
            const _TermsSection(
              title: '7. Contact',
              content:
                  'Pour toute question relative à ces conditions : support@beautyconnect.com.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isLast;

  const _TermsSection({
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
