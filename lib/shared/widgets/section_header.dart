import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Judul section, mis. "Layanan Keuangan" + aksi "Lihat Semua".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
    this.showChevron = true,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  /// Widget kustom di kanan (menggantikan [actionLabel]).
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null)
          trailing!
        else if (actionLabel != null)
          _ActionButton(
            label: actionLabel!,
            onTap: onActionTap,
            showChevron: showChevron,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.showChevron,
    this.onTap,
  });

  final String label;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
