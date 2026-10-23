import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/models/booking.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../services/widgets/service_card.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isTechnician;
  final VoidCallback? onTap;
  const BookingCard(
      {super.key,
      required this.booking,
      this.isTechnician = false,
      this.onTap});

  String get _dateLine {
    final start = booking.dateTime;
    var line =
        '${DateFormat('EEE d MMM yyyy', 'fr_FR').format(start)} · ${DateFormat('HH:mm').format(start)}';
    final duration = booking.service?.durationMinutes;
    if (duration != null && duration > 0) {
      final end = start.add(Duration(minutes: duration));
      line += ' – ${DateFormat('HH:mm').format(end)}';
    }
    return line;
  }

  @override
  Widget build(BuildContext context) {
    final person = isTechnician ? booking.customer : booking.technician;
    final image = person?.profileImage;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.divider)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prestataire / client + chevron
                      Row(children: [
                        CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.navyBackground,
                            backgroundImage: image != null && image.isNotEmpty
                                ? CachedNetworkImageProvider(image)
                                : null,
                            child: image == null || image.isEmpty
                                ? const Icon(LucideIcons.user,
                                    color: AppColors.primary, size: 20)
                                : null),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  person?.fullName ??
                                      (isTechnician
                                          ? booking.customerName
                                          : booking.technicianName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700)),
                              Text(person?.location ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textMedium)),
                            ])),
                        const Icon(LucideIcons.chevronRight,
                            color: AppColors.primary, size: 20),
                      ]),
                      const SizedBox(height: 14),
                      // Service + statut
                      Row(children: [
                        Expanded(
                            child: Text(booking.serviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800))),
                        StatusBadge(status: booking.status),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(LucideIcons.calendar,
                            size: 14, color: AppColors.textMedium),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(_dateLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textMedium))),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                          '${ServiceCard.price(booking.price)} · À régler avec le prestataire',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ]),
              ))),
    );
  }
}
