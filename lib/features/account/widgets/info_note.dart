import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/icon_box.dart';

/// Kotak informasi/tips (gaya sama dengan kartu "Keamanan Terjamin" di
/// Beranda). Bisa punya tombol teks di bawahnya.
class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.icon,
    required this.text,
    this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final IconData icon;
  final String text;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.6),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon: icon, backgroundColor: AppColors.surface, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(text, style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: onActionTap,
                    borderRadius: AppRadius.smAll,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
