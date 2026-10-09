import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Label kecil berbentuk kapsul, mis. "FinPay Premium", "50%", "OJK".
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.leadingIcon,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs + 1,
    ),
    this.textStyle,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? leadingIcon;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 12, color: foregroundColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (textStyle ?? AppTextStyles.labelSmall)
                  .copyWith(color: foregroundColor),
            ),
          ),
        ],
      ),
    );
  }
}
