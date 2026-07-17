import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// Branding header reused across the login/register/forgot-password
/// screens so they read as one consistent flow.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
