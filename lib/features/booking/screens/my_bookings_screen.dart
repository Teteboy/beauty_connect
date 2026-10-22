import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/booking.dart';
import '../widgets/booking_card.dart';
import '../../../core/theme/app_colors.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isTechnician;

  const MyBookingsScreen({
    super.key,
    this.isTechnician = false,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.isTechnician ? 4 : 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final bookingProvider = context.read<BookingProvider>();
    final authProvider = context.read<AuthProvider>();

    if (widget.isTechnician && authProvider.user != null) {
      bookingProvider.fetchTechnicianBookings(authProvider.user!.id);
    } else {
      bookingProvider.fetchBookings();
    }
  }

  List<Booking> _getBookingsByStatus(String status, List<Booking> bookings) {
    return bookings.where((booking) => booking.status == status).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isTechnician ? 'Mes rendez-vous' : 'Mes Réservations'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.accent,
          tabs: [
            if (widget.isTechnician) const Tab(text: 'En attente'),
            Tab(text: widget.isTechnician ? 'Confirmées' : 'À venir'),
            const Tab(text: 'Terminées'),
            const Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.circleAlert, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(bookingProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final bookings = widget.isTechnician
              ? bookingProvider.technicianBookings
              : bookingProvider.customerBookings;

          return TabBarView(
            controller: _tabController,
            children: [
              if (widget.isTechnician)
                _buildBookingsList(_getBookingsByStatus('pending', bookings)),
              _buildBookingsList(widget.isTechnician
                  ? _getBookingsByStatus('confirmed', bookings)
                  : bookings
                      .where((b) => const [
                            'pending',
                            'confirmed',
                            'in_progress'
                          ].contains(b.status))
                      .toList()),
              _buildBookingsList(_getBookingsByStatus('completed', bookings)),
              _buildBookingsList(_getBookingsByStatus('cancelled', bookings)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation pour le moment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            isTechnician: widget.isTechnician,
            onTap: () => context.go('/booking-detail/${booking.id}'),
          );
        },
      ),
    );
  }
}
