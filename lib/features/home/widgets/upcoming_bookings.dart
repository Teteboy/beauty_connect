import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/booking_provider.dart';
import '../../booking/widgets/booking_card.dart';

class UpcomingBookings extends StatelessWidget {
  const UpcomingBookings({super.key});
  @override
  Widget build(BuildContext context) =>
      Consumer<BookingProvider>(builder: (context, provider, _) {
        final bookings = provider.upcomingBookings.take(3).toList();
        if (bookings.isEmpty) return const SizedBox.shrink();
        return Column(
            children: bookings
                .map((booking) => BookingCard(
                    booking: booking,
                    onTap: () => context.go('/booking-detail/${booking.id}')))
                .toList());
      });
}
