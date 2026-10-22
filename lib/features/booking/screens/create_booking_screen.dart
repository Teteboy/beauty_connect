import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/models/service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/business_constants.dart';
import '../../services/widgets/service_card.dart';

class CreateBookingScreen extends StatefulWidget {
  final int serviceId;
  const CreateBookingScreen({super.key, required this.serviceId});
  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime _focusedDay = DateTime.now();
  Service? _service;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr');
    _loadService();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadService() async {
    final service = await context
        .read<ServiceProvider>()
        .fetchServiceById(widget.serviceId);
    if (mounted)
      setState(() {
        _service = service;
        _isLoading = false;
      });
  }

  void _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez choisir une date et un horaire.'),
          backgroundColor: AppColors.error));
      return;
    }
    final dateTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    if (!dateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez choisir un horaire à venir.')));
      return;
    }
    final provider = context.read<BookingProvider>();
    final success = await provider.createBooking(
        serviceId: widget.serviceId,
        dateTime: dateTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Demande de réservation envoyée !'
            : 'Impossible de créer la réservation. Réessayez.'),
        backgroundColor: success ? AppColors.success : AppColors.error));
    if (success) context.go('/my-bookings');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Scaffold(
          appBar: AppBar(title: const Text('Réserver un service')),
          body: const Center(child: CircularProgressIndicator()));
    if (_service == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Réserver un service')),
          body: const Center(child: Text('Service introuvable')));
    final service = _service!;
    return Scaffold(
        appBar: AppBar(title: const Text('Demande de réservation')),
        body: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(16), children: [
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
                  child: TableCalendar<void>(
                      locale: 'fr',
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDate),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: const HeaderStyle(
                          formatButtonVisible: false, titleCentered: true),
                      calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          selectedDecoration: BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                              color: AppColors.orangePale,
                              shape: BoxShape.circle),
                          todayTextStyle: TextStyle(color: AppColors.accent)),
                      onPageChanged: (day) => _focusedDay = day,
                      onDaySelected: (day, focused) => setState(() {
                            _selectedDate = day;
                            _focusedDay = focused;
                          }))),
              const SizedBox(height: 24),
              _title('Choisir un horaire'),
              const SizedBox(height: 12),
              SizedBox(
                  height: 44,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final time = TimeOfDay(hour: 9 + index, minute: 0);
                        final selected = _selectedTime == time;
                        return ChoiceChip(
                            label: Text(
                                '${time.hour.toString().padLeft(2, '0')}:00'),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.navyBackground,
                            labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary),
                            side: BorderSide.none,
                            onSelected: (_) =>
                                setState(() => _selectedTime = time));
                      })),
              const SizedBox(height: 24),
              _title('Notes pour le prestataire'),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText: 'Une envie, une précision ? (facultatif)')),
            ])),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w800))
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
                          onPressed:
                              service.isAvailable ? _createBooking : null))
                ]))));
  }

  Widget _title(String text) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(color: AppColors.primary));
}
