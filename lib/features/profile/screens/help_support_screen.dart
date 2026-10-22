import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/search_field.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<_FAQ> _faqs = [
    _FAQ(
      question: 'Ma demande est-elle confirmée ?',
      answer:
          'Pas encore. Le prestataire doit accepter votre demande. Vous retrouverez ensuite le statut « Confirmée » dans vos réservations.',
    ),
    _FAQ(
      question: 'Comment annuler un rendez-vous ?',
      answer:
          'Ouvrez vos réservations, sélectionnez le rendez-vous puis touchez « Annuler ». L\'annulation est possible jusqu\'à 24h avant.',
    ),
    _FAQ(
      question: 'Comment contacter mon prestataire ?',
      answer:
          'Depuis la fiche du prestataire ou vos réservations, touchez l\'icône de messagerie pour ouvrir une conversation.',
    ),
    _FAQ(
      question: 'Comment modifier mon profil ?',
      answer:
          'Allez dans Mon espace > Modifier le profil pour mettre à jour vos informations.',
    ),
    _FAQ(
      question: 'Comment proposer mes services ?',
      answer:
          'Créez un compte prestataire puis ajoutez vos prestations depuis « Mes services ».',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _query.isEmpty
        ? _faqs
        : _faqs
            .where((f) =>
                f.question.toLowerCase().contains(_query.toLowerCase()) ||
                f.answer.toLowerCase().contains(_query.toLowerCase()))
            .toList();

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
                          'MON ESPACE · ASSISTANCE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Comment vous aider ?',
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
              SearchField(
                controller: _searchController,
                hintText: 'Rechercher dans l\'aide',
                showFilterButton: false,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 24),
              Text(
                'Les réponses à vos questions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              ...filteredFaqs.map((faq) => _FAQItem(faq: faq)),
              if (filteredFaqs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Aucun résultat pour « $_query »',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textLight),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Parlons-en',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orangePale,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.headphones,
                        color: AppColors.accent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Un problème avec une réservation ?',
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
                            'Indiquez la référence de votre réservation et décrivez la situation à notre équipe.',
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
              const SizedBox(height: 16),
              CustomButton(
                text: 'Signaler un problème de réservation',
                onPressed: () => _reportIssue(context),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Contacter le support',
                isOutlined: true,
                onPressed: () => _sendEmail(),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Vous pouvez aussi nous joindre au',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _callSupport,
                      child: Text(
                        '+237 6 57 78 37 84',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accent,
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
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@beautyconnect.com',
      query: 'subject=Demande d\'assistance',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+237657783784');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _reportIssue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Signaler un problème'),
        content: const Text(
          'Écrivez-nous à support@beautyconnect.com avec la référence de votre réservation et une description du problème.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmail();
            },
            child: const Text('Envoyer un e-mail',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final _FAQ faq;

  const _FAQItem({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          iconColor: AppColors.accent,
          collapsedIconColor: AppColors.textLight,
          title: Text(
            faq.question,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ({
    required this.question,
    required this.answer,
  });
}
