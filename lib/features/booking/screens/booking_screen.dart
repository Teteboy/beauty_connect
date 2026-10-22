import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../services/widgets/service_card.dart';
import '../../../core/utils/navigation.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  const BookingScreen({super.key, required this.serviceId});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Service? _service;
  bool _isLoadingService = true;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedTimeSlot;
  List<DateTime> _availableSlots = [];
  final _notesController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr');
    _loadService();
    _generateAvailableSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadService() async {
    try {
      final service = await context
          .read<ServiceProvider>()
          .fetchServiceById(int.parse(widget.serviceId));
      if (mounted)
        setState(() {
          _service = service;
          _isLoadingService = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoadingService = false);
    }
  }

  void _generateAvailableSlots() {
    final slots = <DateTime>[];
    final baseDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    for (int hour = 9; hour <= 18; hour++) {
      final slot = baseDate.add(Duration(hours: hour));
      if (slot.isAfter(DateTime.now())) slots.add(slot);
    }
    setState(() {
      _availableSlots = slots;
      _selectedTimeSlot = null;
    });
  }

  Future<void> _bookService() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir un horaire.')));
      return;
    }
    final success = await context.read<BookingProvider>().createBooking(
        serviceId: int.parse(widget.serviceId),
        dateTime: _selectedTimeSlot!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim());
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Demande de réservation envoyée !'),
          backgroundColor: AppColors.success));
      safePop(context, fallback: context.read<AuthProvider>().user?.isTechnician == true ? '/technician-bookings' : '/my-bookings');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible de créer la réservation. Réessayez.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingService)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_service == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Réserver un service')),
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Service introuvable'),
            TextButton(
                onPressed: () => context.go('/services'),
                child: const Text('Découvrir les services'))
          ])));
    final service = _service!;
    return Scaffold(
        appBar: AppBar(title: const Text('Demande de réservation')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(service.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(
              '${ServiceCard.price(service.price)} · ${service.durationMinutes} min',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(service.description),
          const SizedBox(height: 24),
          _title('Choisir une date'),
          const SizedBox(height: 12),
          Container(
              decoration: BoxDecoration(
                  color: AppColors.navyBackground,
                  borderRadius: BorderRadius.circular(16)),
              child: TableCalendar<DateTime>(
                  locale: 'fr',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                      formatButtonVisible: false, titleCentered: true),
                  calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: AppColors.orangePale, shape: BoxShape.circle),
                      todayTextStyle: TextStyle(color: AppColors.accent)),
                  onPageChanged: (day) => _focusedDay = day,
                  onDaySelected: (day, focused) {
                    setState(() {
                      _selectedDate = day;
                      _focusedDay = focused;
                    });
                    _generateAvailableSlots();
                  },
                  enabledDayPredicate: (day) => day.isAfter(
                      DateTime.now().subtract(const Duration(days: 1))))),
          const SizedBox(height: 24),
          _title('Choisir un horaire'),
          const SizedBox(height: 12),
          if (_availableSlots.isEmpty)
            const Text('Aucun horaire disponible pour cette date.')
          else
            SizedBox(
                height: 44,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableSlots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      final selected = slot == _selectedTimeSlot;
                      return ChoiceChip(
                          label: Text(
                              '${slot.hour.toString().padLeft(2, '0')}:00'),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.navyBackground,
                          labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.primary),
                          side: BorderSide.none,
                          onSelected: (_) =>
                              setState(() => _selectedTimeSlot = slot));
                    })),
          const SizedBox(height: 24),
          _title('Notes pour le prestataire'),
          const SizedBox(height: 8),
          TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Une envie, une précision ? (facultatif)')),
        ]),
        bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, boxShadow: AppColors.sheetShadow),
            child: SafeArea(
                top: false,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total du service'),
                        Text(ServiceCard.price(service.price),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20))
                      ]),
                  const SizedBox(height: 6),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Frais de réservation : ${ServiceCard.price(kBookingFeeXaf)}',
                          style: Theme.of(context).textTheme.bodySmall)),
                  const SizedBox(height: 12),
                  Consumer<BookingProvider>(
                      builder: (context, provider, _) => CustomButton(
                          text: 'Confirmer la réservation',
                          isLoading: provider.isLoading,
                          onPressed: service.isAvailable ? _bookService : null))
                ]))));
  }

  Widget _title(String text) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(color: AppColors.primary));
}
