import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beauty_connect/main.dart';
import 'package:beauty_connect/core/providers/auth_provider.dart';
import 'package:beauty_connect/core/providers/service_provider.dart';
import 'package:beauty_connect/core/providers/booking_provider.dart';
import 'package:beauty_connect/core/providers/review_provider.dart';
import 'package:beauty_connect/core/providers/chat_provider.dart';
import 'package:beauty_connect/core/providers/message_provider.dart';
import 'package:beauty_connect/core/providers/notification_provider.dart';
import 'package:beauty_connect/core/providers/profile_provider.dart';
import 'package:beauty_connect/core/providers/analytics_provider.dart';

void main() {
  testWidgets('App builds and shows splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ServiceProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => ReviewProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => MessageProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsWidgets);
    expect(find.text('Votre beauté, notre connexion'), findsOneWidget);

    // Advance past the splash screen timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
