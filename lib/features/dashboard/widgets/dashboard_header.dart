import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/app_toast.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';

/// Dashboard's top banner: a time-of-day greeting, the user's profile
/// avatar (tapping it jumps to the Profile tab), and a notifications
/// entry point.
class DashboardHeader extends StatefulWidget {
  final String? fullName;
  final String? avatarUrl;

  const DashboardHeader({super.key, this.fullName, this.avatarUrl});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String? _failedAvatarUrl;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.fullName?.trim().split(' ').first;
    final avatarUrl = widget.avatarUrl;
    final avatarLoadFailed = avatarUrl != null && avatarUrl == _failedAvatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName ?? 'Welcome back',
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _NotificationButton(
          onPressed: () => AppToast.show(context, 'No new notifications'),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.go(AppRoutes.profile),
          child: Hero(
            tag: 'profile-avatar',
            child: CircleAvatar(
              radius: 22,
              backgroundColor: context.colors.primaryContainer,
              backgroundImage: avatarUrl != null && !avatarLoadFailed
                  ? CachedNetworkImageProvider('${AppConfig.apiOrigin}$avatarUrl')
                  : null,
              onBackgroundImageError: avatarUrl != null && !avatarLoadFailed
                  ? (_, _) {
                      if (mounted && _failedAvatarUrl != avatarUrl) {
                        setState(() => _failedAvatarUrl = avatarUrl);
                      }
                    }
                  : null,
              child: avatarUrl == null || avatarLoadFailed
                  ? Icon(
                      Icons.person_outline_rounded,
                      color: context.colors.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NotificationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.notifications_none_rounded,
          color: context.colors.onSurface,
        ),
        tooltip: 'Notifications',
      ),
    );
  }
}
