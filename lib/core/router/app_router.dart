import 'package:beauty_connect/features/users/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Screens
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/home/screens/technician_home_screen.dart';
import '../../features/services/screens/service_detail_screen.dart';
import '../../features/services/screens/add_service_screen.dart';
import '../../features/services/screens/my_services_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/services/screens/edit_service_screen.dart';
import '../../features/services/screens/service_catalogue_screen.dart';
import '../../features/booking/screens/booking_detail_screen.dart';
import '../../features/booking/screens/deposit_payment_screen.dart';
import '../../features/booking/screens/bookings_screen.dart';
import '../../features/booking/screens/technician_bookings_screen.dart';
import '../../features/booking/screens/create_booking_screen.dart';
import '../../features/home/screens/recommendations_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/messages/screens/messages_screen.dart';
import '../../features/messages/screens/video_call_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/payment_methods_screen.dart';
import '../../features/profile/screens/earnings_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/review/screens/review_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/analytics_screen.dart';
import '../../features/profile/screens/about_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/favorites_screen.dart';
import '../../features/profile/screens/availability_screen.dart';
import '../../features/profile/screens/verification_screen.dart';
import '../../features/profile/screens/subscription_screen.dart';
import '../../features/profile/screens/whatsapp_preferences_screen.dart';

// Providers
import '../providers/auth_provider.dart';
import '../widgets/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final user = authProvider.user;
      final location = state.matchedLocation;

      // Public routes that don't require authentication
      final publicRoutes = [
        '/',
        '/onboarding',
        '/role-selection',
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
      ];

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !publicRoutes.contains(location)) {
        return '/login';
      }

      // If logged in and trying to access auth routes, redirect based on role
      if (isLoggedIn && ['/login', '/register'].contains(location)) {
        if (user?.role == 'technician') {
          return '/technician-home';
        }
        return '/home';
      }

      // If logged in and accessing /home, redirect technicians to their dashboard
      if (isLoggedIn && location == '/home' && user?.role == 'technician') {
        return '/technician-home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Role Selection
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterScreen(initialRole: state.extra as String?),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // Main App Routes with Bottom Navigation
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(child: MainScreen()),
      ),

      // Technician Dashboard
      GoRoute(
        path: '/technician-home',
        builder: (context, state) =>
            const MainLayout(child: TechnicianHomeScreen()),
      ),

      // Service Routes with Bottom Navigation
      GoRoute(
        path: '/services',
        builder: (context, state) => const MainLayout(child: ServicesScreen()),
      ),
      GoRoute(
        path: '/my-services',
        builder: (context, state) =>
            const MainLayout(child: MyServicesScreen()),
      ),
      // Service detail and add service don't need bottom nav
      GoRoute(
        path: '/service/:id',
        builder: (context, state) {
          final serviceId = state.pathParameters['id']!;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/add-service',
        builder: (context, state) => const AddServiceScreen(),
      ),
      GoRoute(
        path: '/edit-service/:id',
        builder: (context, state) {
          final serviceId = state.pathParameters['id']!;
          return EditServiceScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/service-catalogue/:id',
        builder: (context, state) {
          final serviceId = state.pathParameters['id']!;
          return ServiceCatalogueScreen(serviceId: serviceId);
        },
      ),

      // Booking Routes with Bottom Navigation
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MainLayout(child: BookingsScreen()),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MainLayout(child: BookingsScreen()),
      ),
      GoRoute(
        path: '/technician-bookings',
        builder: (context, state) =>
            const MainLayout(child: TechnicianBookingsScreen()),
      ),
      // Booking screens without bottom nav
      GoRoute(
        path: '/book/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/booking-detail/:id',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return BookingDetailScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/create-booking/:serviceId',
        builder: (context, state) {
          final serviceId = int.parse(state.pathParameters['serviceId']!);
          return CreateBookingScreen(serviceId: serviceId);
        },
      ),

      // Profile Routes with Bottom Navigation
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainLayout(child: ProfileScreen()),
      ),

      // Messages Routes with Bottom Navigation
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MainLayout(child: MessagesScreen()),
      ),

      // Profile sub-screens without bottom nav
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/whatsapp-preferences',
        builder: (context, state) => const WhatsappPreferencesScreen(),
      ),

      // Notification Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Chat Routes
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatScreen(userId: userId);
        },
      ),

      // Users Routes with Bottom Navigation
      GoRoute(
        path: '/users',
        builder: (context, state) => const MainLayout(child: UsersScreen()),
      ),

      // Future-concept Routes (no bottom nav — full-screen flows)
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/deposit/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return DepositPaymentScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: '/video-call/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return VideoCallScreen(
            userId: userId,
            peerName: state.extra as String?,
          );
        },
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),

      // Review Routes
      GoRoute(
        path: '/review/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return ReviewScreen(bookingId: bookingId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
