import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'customer_home_screen.dart';
import 'technician_home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return user.role == 'technician'
            ? const TechnicianHomeScreen()
            : const CustomerHomeScreen();
      },
    );
  }
}
