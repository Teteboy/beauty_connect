import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _titles = [
    'Découvrez des experts près de chez vous',
    'Réservez en quelques secondes',
    'Hommes & Femmes, services pour tous',
  ];
  static const _eyebrows = [
    'L’EXPERTISE, TOUT PRÈS',
    'VOTRE TEMPS EST PRÉCIEUX',
    'LA BEAUTÉ N’A PAS DE GENRE',
  ];
  static const _descriptions = [
    'Des talents locaux, des prix clairs. Trouvez la personne qui prendra soin de vous, à Douala et au-delà.',
    'Choisissez votre service et votre créneau. Le prestataire reçoit votre demande et vous répond.',
    'Coiffure, barbier, ongles, fitness et bien-être : un même espace pour toutes vos envies.',
  ];

  Future<void> _completeOnboarding() async {
    await StorageService().setBool('has_seen_onboarding', true);
    if (mounted) context.go('/role-selection');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              const Text('BEAUTYCONNECT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Passer')),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _illustration(index),
                      const SizedBox(height: 48),
                      Text(_eyebrows[index],
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      Text(_titles[index],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 20),
                      Text(_descriptions[index],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, height: 1.4)),
                    ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(children: [
              Row(
                  children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: index == _currentPage ? 28 : 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                                color: index == _currentPage
                                    ? AppColors.accent
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                          ))),
              const SizedBox(height: 26),
              CustomButton(
                  text: _currentPage == 2 ? 'Commencer' : 'Suivant',
                  onPressed: () {
                    if (_currentPage == 2) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  }),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _illustration(int index) {
    return Container(
      height: 290,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: index == 1
                ? [AppColors.accent, AppColors.amber]
                : [AppColors.midNavy, AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: index == 1
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.calendarCheck,
                  color: Colors.white, size: 44),
              const Spacer(),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tresses collées',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 10),
                        Text('Amina Njoya · Bonapriso'),
                        SizedBox(height: 10),
                        Text('Sam. 24 octobre · 10:00',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 12),
                        Text('Demande envoyée',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700)),
                      ])),
            ])
          : Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Icon(
                      index == 0
                          ? LucideIcons.scissors
                          : LucideIcons.sparkles,
                      size: 82,
                      color: Colors.white),
                  Icon(
                      index == 0
                          ? LucideIcons.mapPin
                          : LucideIcons.flower,
                      size: 82,
                      color: AppColors.amber),
                ])),
    );
  }
}
