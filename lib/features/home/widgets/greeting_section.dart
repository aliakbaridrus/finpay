import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Sapaan pengguna + status membership & poin.
class GreetingSection extends StatelessWidget {
  const GreetingSection({
    super.key,
    required this.userName,
    required this.membership,
    required this.points,
  });

  final String userName;
  final String membership;
  final int points;

  String get _formattedPoints {
    final s = points.toString();
    return s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $userName 👋',
                style: AppTextStyles.h1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PillBadge(
                    label: membership,
                    leadingIcon: Icons.workspace_premium_rounded,
                    backgroundColor: AppColors.goldLight,
                    foregroundColor: const Color(0xFF92400E),
                  ),
                  Text(
                    '• $_formattedPoints FinPoin',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Material(
          color: AppColors.primaryLight,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {},
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: AppSizes.iconMd,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
