import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';
import '../../../core/widgets/custom_button.dart';

/// Future-concept screen (prestataire): simulated balance, monthly earnings
/// chart and payout (reversement) history. Demo data — the backend exposes no
/// payout endpoints yet; completed bookings are used when available.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // ── Demo data ─────────────────────────────────────────────────────────
  static const _monthlyGains = <String, double>{
    'Mai': 98000,
    'Juin': 124000,
    'Juil': 86000,
    'Août': 152000,
    'Sept': 131000,
    'Oct': 186000,
  };

  static const _activity = [
    _EarningEntry('Prestation · Tresses collées', '18 octobre', 8000),
    _EarningEntry('Prestation · Soin hydratant', '15 octobre', 5000),
    _EarningEntry('Prestation · Maquillage soirée', '12 octobre', 15000),
    _EarningEntry('Prestation · Pose de perruque', '8 octobre', 12000),
  ];

  static const _payouts = [
    _PayoutEntry('Versement prévu', 'Mobile Money', 142000, 'Non exécuté'),
    _PayoutEntry(
        'Versement de septembre', 'Mobile Money', 118000, 'Simulation · Reçu'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && user.role == 'technician') {
        context.read<BookingProvider>().fetchTechnicianBookings(user.id);
      }
    });
  }

  String _money(num v) =>
      '${NumberFormat('#,##0', 'fr_FR').format(v).replaceAll(' ', ' ').replaceAll(' ', ' ')}';

  void _requestPayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Demande de versement'),
        content: const Text(
          'Concept · À venir\n\nVotre demande de versement de 142 000 CFA '
          'vers Mobile Money a été simulée. Aucune opération réelle n\'est '
          'effectuée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().bookings;
    final completed = bookings.where((b) => b.status == 'completed').toList();
    // Prefer real completed bookings when available, else demo activity.
    final entries = completed.isNotEmpty
        ? completed
            .take(6)
            .map((b) => _EarningEntry(
                  'Prestation · ${b.serviceName}',
                  DateFormat('dd/MM/yyyy').format(b.dateTime),
                  b.price.toInt(),
                ))
            .toList()
        : _activity;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const ConceptHeader(title: 'Gains et reversements'),
            const SizedBox(height: 16),
            const ConceptBanner(),
            const SizedBox(height: 20),

            // ── Navy balance card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SOLDE SIMULÉ · OCTOBRE 2026',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          )),
                  const SizedBox(height: 8),
                  Text('${_money(186000)} CFA',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Chiffres illustratifs · Aucun versement actif',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Available / pending tiles ─────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _statTile('142 000', 'CFA disponibles · Exemple')),
                const SizedBox(width: 12),
                Expanded(
                    child: _statTile('44 000', 'CFA en attente · Exemple')),
              ],
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Demander un versement · Concept',
              onPressed: _requestPayout,
            ),
            const SizedBox(height: 24),

            // ── Monthly bar chart (Containers only) ───────────────────
            Text('Gains mensuels · Simulation',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: _BarChart(data: _monthlyGains),
            ),
            const SizedBox(height: 24),

            // ── Simulated activity ────────────────────────────────────
            Text('Activité simulée',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...entries.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${e.date} · + ${_money(e.amount)} CFA · Simulation',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMedium)),
                  trailing: const Icon(LucideIcons.chevronRight,
                      color: AppColors.textLight),
                )),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),

            // ── Payout history ────────────────────────────────────────
            Text('Reversements',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ..._payouts.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${p.method} · ${_money(p.amount)} CFA · ${p.status}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMedium)),
                  trailing: const Icon(LucideIcons.clock,
                      color: AppColors.textLight),
                )),
            const SizedBox(height: 16),
            Text(
              'Conditions de reversement et commissions à définir.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _EarningEntry {
  final String label;
  final String date;
  final int amount;
  const _EarningEntry(this.label, this.date, this.amount);
}

class _PayoutEntry {
  final String label;
  final String method;
  final int amount;
  final String status;
  const _PayoutEntry(this.label, this.method, this.amount, this.status);
}

/// Simple bar chart built with Containers — no chart dependency.
class _BarChart extends StatelessWidget {
  final Map<String, double> data;

  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final max = data.values.fold(0.0, (a, b) => a > b ? a : b);
    final entries = data.entries.toList();

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < entries.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: max == 0 ? 0 : entries[i].value / max,
                        child: Container(
                          decoration: BoxDecoration(
                            color: i == entries.length - 1
                                ? AppColors.accent
                                : AppColors.midNavy.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(entries[i].key,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textLight)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
