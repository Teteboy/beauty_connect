import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final storageService = StorageService();

    final hasSeenOnboarding =
        await storageService.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }

    await authProvider.initialize();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text('BEAUTÉ · BIEN-ÊTRE · PROXIMITÉ',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              const SizedBox(height: 28),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 39),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28)),
                child: const AppLogo(size: 184, full: true),
              ),
              const SizedBox(height: 24),
              Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 28),
              const Text('Votre beauté, notre connexion',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic)),
              const Spacer(),
              Text(
                'DOUALA · YAOUNDÉ · ET TOUT PRÈS DE VOUS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
