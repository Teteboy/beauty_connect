import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/user.dart';
import '../../../core/models/service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../services/widgets/service_card.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});
  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Booking? _booking;
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  void _loadBooking() async {
    try {
      final booking = await context
          .read<BookingProvider>()
          .fetchBookingById(widget.bookingId);
      if (mounted)
        setState(() {
          _booking = booking;
          _isLoading = false;
          _error = booking == null ? 'Réservation introuvable' : null;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _error = 'Impossible de charger la réservation';
          _isLoading = false;
        });
    }
  }

  void _updateBookingStatus(String status) async {
    if (_booking == null) return;
    final success = await context
        .read<BookingProvider>()
        .updateBookingStatus(_booking!.id, status);
    if (!mounted) return;
    if (success) setState(() => _booking = _booking!.copyWith(status: status));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Réservation mise à jour.'
            : 'Impossible de modifier la réservation. Réessayez.'),
        backgroundColor: success ? AppColors.success : AppColors.error));
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(context.read<AuthProvider>().user?.role == 'technician'
          ? '/technician-bookings'
          : '/bookings');
    }
  }

  void _showCancelConfirmation(String status) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Annuler la réservation ?'),
                content: const Text('Cette action est définitive.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Conserver')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateBookingStatus(status);
                      },
                      child: const Text('Annuler'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        title: const Text('Votre rendez-vous'),
        leading: IconButton(
            onPressed: _navigateBack,
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary)));
    if (_isLoading)
      return Scaffold(
          appBar: appBar,
          body: const Center(child: CircularProgressIndicator()));
    if (_error != null || _booking == null)
      return Scaffold(
          appBar: appBar,
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.circleAlert,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(_error ?? 'Réservation introuvable'),
                    const SizedBox(height: 20),
                    CustomButton(
                        text: 'Réessayer',
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadBooking();
                        })
                  ]))));
    final booking = _booking!;
    final isTechnician =
        context.read<AuthProvider>().user?.role == 'technician';
    final person = isTechnician ? booking.customer : booking.technician;
    final active = const ['pending', 'confirmed'].contains(booking.status);
    final image = person?.profileImage;
    final completed = booking.status == 'completed';
    final confirmed = const ['confirmed', 'in_progress', 'completed']
        .contains(booking.status);
    return Scaffold(
      appBar: appBar,
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Text('RÉSERVATION BC-${booking.id}',
                  style: Theme.of(context).textTheme.bodySmall)),
          StatusBadge(status: booking.status)
        ]),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.navyBackground,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircleAvatar(
                  radius: 26,
                  backgroundImage: image != null && image.isNotEmpty
                      ? NetworkImage(image)
                      : null,
                  child: image == null || image.isEmpty
                      ? const Icon(LucideIcons.user)
                      : null),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        person?.fullName ??
                            (isTechnician ? 'Client' : booking.technicianName),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    if (person?.specialty != null)
                      Text(person!.specialty!,
                          style: Theme.of(context).textTheme.bodySmall),
                    if (person?.location != null)
                      Text(person!.location!,
                          style: Theme.of(context).textTheme.bodySmall)
                  ]))
            ])),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppColors.cardShadow),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.serviceName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 12),
              Text(
                  '${DateFormat('dd/MM/yyyy').format(booking.dateTime)} · ${DateFormat('HH:mm').format(booking.dateTime)}'),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Service · ${booking.service?.durationMinutes ?? 0} min'),
                Text(ServiceCard.price(booking.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.primary))
              ]),
              const SizedBox(height: 12),
              const Text('Aucun paiement effectué dans l’application.',
                  style: TextStyle(color: AppColors.textLight, fontSize: 11)),
            ])),
        const SizedBox(height: 24),
        Text('Suivi de la réservation',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 20),
        _step('Demandée',
            DateFormat('dd/MM/yyyy · HH:mm').format(booking.createdAt), true),
        _step(
            'Confirmée',
            confirmed
                ? 'Votre rendez-vous est confirmé'
                : 'En attente du prestataire',
            confirmed),
        _step(
            booking.status == 'cancelled' ? 'Annulée' : 'Terminée',
            booking.status == 'cancelled'
                ? 'Cette réservation a été annulée'
                : completed
                    ? 'Prestation terminée'
                    : 'Après la prestation',
            completed || booking.status == 'cancelled'),
        if (booking.notes?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text('Notes pour le prestataire',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(booking.notes!)
        ],
        if (isTechnician && person != null) ...[
          const SizedBox(height: 16),
          if (person.phone != null) Text('Téléphone : ${person.phone}'),
          Text('E-mail : ${person.email}')
        ],
        if (completed && !isTechnician)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CustomButton(
                  text: 'Donner un avis',
                  isOutlined: true,
                  onPressed: () => context.go('/review/${booking.id}'))),
      ]),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider))),
          child: SafeArea(
              top: false,
              child: Consumer<BookingProvider>(
                  builder: (context, provider, _) =>
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        if (isTechnician && booking.status == 'pending') ...[
                          CustomButton(
                              text: 'Confirmer la réservation',
                              isLoading: provider.isLoading,
                              onPressed: () =>
                                  _updateBookingStatus('confirmed')),
                          const SizedBox(height: 8),
                          CustomButton(
                              text: 'Refuser la demande',
                              isOutlined: true,
                              isLoading: provider.isLoading,
                              onPressed: () =>
                                  _showCancelConfirmation('cancelled'))
                        ],
                        if (isTechnician && booking.status == 'confirmed')
                          CustomButton(
                              text: 'Marquer comme terminée',
                              isLoading: provider.isLoading,
                              onPressed: () =>
                                  _updateBookingStatus('completed')),
                        if (!isTechnician && active) ...[
                          CustomButton(
                              text: 'Payer l\'acompte · Concept',
                              isOutlined: true,
                              onPressed: () =>
                                  context.push('/deposit/${booking.id}')),
                          const SizedBox(height: 8)
                        ],
                        if (!isTechnician)
                          Row(children: [
                            if (active) ...[
                              Expanded(
                                  child: CustomButton(
                                      text: 'Annuler',
                                      isOutlined: true,
                                      isLoading: provider.isLoading,
                                      onPressed: () => _showCancelConfirmation(
                                          'cancelled'))),
                              const SizedBox(width: 12)
                            ],
                            Expanded(
                                child: CustomButton(
                                    text: 'Contacter',
                                    onPressed: () => context
                                        .go('/chat/${booking.technicianId}')))
                          ]),
                      ])))),
    );
  }

  Widget _step(String title, String subtitle, bool reached) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? AppColors.primary : Colors.white,
                border: Border.all(color: AppColors.primary)),
            child: reached
                ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                : null),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
        ]))
      ]));
}

extension BookingExtension on Booking {
  Booking copyWith(
          {String? id,
          int? customerId,
          int? technicianId,
          int? serviceId,
          DateTime? dateTime,
          String? status,
          String? notes,
          double? price,
          User? customer,
          User? technician,
          Service? service,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Booking(
          id: id ?? this.id,
          customerId: customerId ?? this.customerId,
          technicianId: technicianId ?? this.technicianId,
          serviceId: serviceId ?? this.serviceId,
          dateTime: dateTime ?? this.dateTime,
          status: status ?? this.status,
          notes: notes ?? this.notes,
          price: price ?? this.price,
          customer: customer ?? this.customer,
          technician: technician ?? this.technician,
          service: service ?? this.service,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);
}
