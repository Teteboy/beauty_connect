import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'app_logo.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showLogo;
  final bool showNotification;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = false,
    this.showNotification = true,
    this.showBack = false,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.chipBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          if (showBack) const SizedBox(width: 12),
          if (showLogo)
            Row(
              children: [
                const AppLogo(size: 40, circular: false),
                const SizedBox(width: 12),
                Text(
                  'BeautyConnect',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textMedium,
                            letterSpacing: 1,
                          ),
                    ),
                  if (title != null)
                    Text(
                      title!,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                ],
              ),
            ),
          if (showNotification)
            Stack(
              children: [
                IconButton(
                  onPressed: () => context.go('/notifications'),
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textDark),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.chipBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<NotificationProvider>(
                    builder: (context, provider, _) {
                      if (provider.unreadCount <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          if (user != null && !showLogo) ...[
            const SizedBox(width: 12),
            _UserAvatar(user: user),
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final dynamic user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImage;
    return GestureDetector(
      onTap: () {},
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl == null || imageUrl.isEmpty
            ? Text(
                user.initials ?? 'U',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            : null,
      ),
    );
  }
}
