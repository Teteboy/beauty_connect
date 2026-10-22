import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/review_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  final Set<String> _selectedTags = {};

  // Quick-impression tags from the "Votre avis compte" Figma frame.
  static const _tags = ['À l\'écoute', 'Travail soigné', 'Ponctuelle'];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConceptHeader(
                          title: 'Votre avis compte', onBack: _navigateBack),
                      const SizedBox(height: 16),
                      const ConceptBanner(),
                      const SizedBox(height: 20),

                      // Booking context card
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.orangePale,
                            child: Icon(LucideIcons.user,
                                color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Votre soin avec Amina',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                Text(
                                  'Soin hydratant · Jeu. 15 octobre\n'
                                  'Réservation terminée',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textMedium,
                                          height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text('Comment s\'est passée votre\nvisite ?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15)),
                      const SizedBox(height: 20),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final selected = index < _rating;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = index + 1),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                selected
                                    ? LucideIcons.star
                                    : LucideIcons.star,
                                size: 44,
                                color: selected
                                    ? AppColors.amber
                                    : AppColors.amber.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _rating == 0
                              ? 'Touchez une étoile pour noter'
                              : '$_rating / 5 · ${_getRatingText(_rating)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          final selected = _selectedTags.contains(tag);
                          return ChoiceChip(
                            label: Text(tag),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) => setState(() {
                              selected
                                  ? _selectedTags.remove(tag)
                                  : _selectedTags.add(tag);
                            }),
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.navyBackground,
                            labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      Text('Votre commentaire',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _commentController,
                        label: 'Racontez votre expérience (facultatif)',
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_commentController.text.length}/500',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _commentController.text.length > 500
                                        ? AppColors.error
                                        : AppColors.textLight,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trust note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.navyBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.badgeCheck,
                                color: AppColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Des avis utiles et authentiques',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Seuls les clients d\'une prestation '
                                    'terminée pourront laisser un avis. '
                                    'Votre prénom sera visible.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.textMedium,
                                            height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Consumer<ReviewProvider>(
                builder: (context, reviewProvider, _) {
                  return CustomButton(
                    text: 'Publier l\'avis',
                    isLoading: reviewProvider.isLoading,
                    onPressed: _rating > 0 && !reviewProvider.isLoading
                        ? _submitReview
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBack() {
    final currentUser = context.read<AuthProvider>().user;
    final isTechnician = currentUser?.role == 'technician';
    if (isTechnician) {
      context.go('/technician-bookings');
    } else {
      context.go('/bookings');
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Une expérience décevante';
      case 2:
        return 'Une expérience mitigée';
      case 3:
        return 'Une bonne expérience';
      case 4:
        return 'Une très bonne expérience';
      case 5:
        return 'Une excellente expérience';
      default:
        return '';
    }
  }

  void _submitReview() async {
    if (_commentController.text.length > 500) {
      _showSnack(
          'Le commentaire doit faire moins de 500 caractères', AppColors.error);
      return;
    }

    final reviewProvider = context.read<ReviewProvider>();
    FocusScope.of(context).unfocus();

    // Append selected quick tags to the comment for context.
    var comment = _commentController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tags = _selectedTags.join(' · ');
      comment = comment.isEmpty ? tags : '$comment\n$tags';
    }

    try {
      final success = await reviewProvider.createReview(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: comment,
      );

      if (mounted) {
        if (success) {
          _showSnack('Avis publié avec succès !', AppColors.success);
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) _navigateBack();
        } else {
          _showSnack(reviewProvider.error ?? 'Échec de la publication',
              AppColors.error);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erreur : ${e.toString()}', AppColors.error);
      }
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
