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
  @override
  Widget build(BuildContext context) {
    final person = isTechnician ? booking.customer : booking.technician;
    final image = person?.profileImage;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.divider)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.navyBackground,
                            backgroundImage: image != null && image.isNotEmpty
                                ? NetworkImage(image)
                                : null,
                            child: image == null || image.isEmpty
                                ? const Icon(LucideIcons.user,
                                    color: AppColors.primary)
                                : null),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  person?.fullName ??
                                      (isTechnician
                                          ? 'Client'
                                          : booking.technicianName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text(booking.serviceName,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ]))
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        const Icon(LucideIcons.calendar,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                '${DateFormat('dd/MM/yyyy').format(booking.dateTime)} · ${DateFormat('HH:mm').format(booking.dateTime)}',
                                style: Theme.of(context).textTheme.bodySmall)),
                        StatusBadge(status: booking.status)
                      ]),
                      const SizedBox(height: 12),
                      Text(ServiceCard.price(booking.price),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                      if (booking.notes?.isNotEmpty == true)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(booking.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall)),
                    ]),
              ))),
    );
  }
}
