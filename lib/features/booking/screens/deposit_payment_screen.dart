import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/business_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';
import '../../../core/widgets/custom_button.dart';

/// Future-concept screen: pay the flat booking fee (acompte) before a booking.
/// Demo only — the backend exposes no payment endpoint yet.
class DepositPaymentScreen extends StatefulWidget {
  final String bookingId;

  const DepositPaymentScreen({super.key, required this.bookingId});

  @override
  State<DepositPaymentScreen> createState() => _DepositPaymentScreenState();
}

class _DepositPaymentScreenState extends State<DepositPaymentScreen> {
  // ── Demo data (no payment/booking-pricing endpoint available) ──────────
  static const _demoServiceName = 'Tresses collées';
  static const _demoProviderName = 'Amina Njoya';
  static const _demoSchedule = 'Sam. 24 octobre · 10:00 · Exemple';
  static const _demoPriceXaf = 8000;

  static const _methods = [
    _PayMethod(
        'orange_money',
        'Orange Money',
        '+237 6 77 •• •• 56 · Compte de démonstration',
        Icons.smartphone_outlined),
    _PayMethod('mtn_momo', 'MTN Mobile Money', 'Ajouter un numéro · Concept',
        Icons.smartphone_outlined),
    _PayMethod('card', 'Carte bancaire', 'Disponible selon le futur partenaire',
        Icons.credit_card_outlined),
  ];

  String _selectedMethod = 'orange_money';
  bool _processing = false;
  bool _paid = false;

  String _money(num v) =>
      '${NumberFormat('#,##0', 'fr_FR').format(v).replaceAll(' ', ' ').replaceAll(' ', ' ')} CFA';

  Future<void> _pay() async {
    setState(() => _processing = true);
    // Simulated authorization delay — no real payment is performed.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _processing = false;
      _paid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: _paid ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    const deposit = kBookingFeeXaf;
    final balance = _demoPriceXaf - deposit;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const ConceptHeader(title: 'Préparer un acompte'),
              const SizedBox(height: 16),
              const ConceptBanner(),
              const SizedBox(height: 20),

              // ── Booking summary ─────────────────────────────────────
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.orangePale,
                    child: Icon(Icons.person_outline, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_demoServiceName · $_demoProviderName',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(_demoSchedule,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Transaction recap ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Résumé de la transaction',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _row('Prix du service', _money(_demoPriceXaf)),
                    _row('Acompte · Frais de réservation', _money(deposit),
                        highlight: true),
                    _row('Frais de service · Simulation', _money(0)),
                    const Divider(height: 24, color: AppColors.divider),
                    _row('Solde après prestation', _money(balance)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Payment method selector ─────────────────────────────
              Text('Moyen de paiement',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ..._methods.map((m) {
                final selected = m.id == _selectedMethod;
                return InkWell(
                  onTap: () => setState(() => _selectedMethod = m.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.divider,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(m.icon,
                            color: selected
                                ? AppColors.accent
                                : AppColors.textLight),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(m.subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textMedium)),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color:
                              selected ? AppColors.accent : AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Une transaction ne confirme pas à elle seule la disponibilité '
                'du prestataire.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textLight, height: 1.35),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CustomButton(
            text: 'Payer l\'acompte · ${_money(kBookingFeeXaf)}',
            isLoading: _processing,
            onPressed: _processing ? null : _pay,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.orangePale,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 24),
          Text('Acompte simulé avec succès',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            '${_money(kBookingFeeXaf)} · ${_methods.firstWhere((m) => m.id == _selectedMethod).label}\n'
            'Aucun débit réel n\'a été effectué. Le solde sera réglé après '
            'la prestation.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMedium, height: 1.5),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Voir ma réservation',
            onPressed: () => context.go('/booking-detail/${widget.bookingId}'),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Retour à l\'accueil',
            isOutlined: true,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMedium)),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.accent : AppColors.textDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _PayMethod {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  const _PayMethod(this.id, this.label, this.subtitle, this.icon);
}
