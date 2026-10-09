import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/menu_item_data.dart';
import 'icon_box.dart';

/// Ikon menu + label + badge opsional.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.item,
    this.boxSize = AppSizes.serviceIconBox,
    this.iconSize = AppSizes.iconMd,
    this.labelStyle,
    this.onTap,
  });

  final MenuItemData item;
  final double boxSize;
  final double iconSize;
  final TextStyle? labelStyle;
  final VoidCallback? onTap;

  bool get _isHighlighted => item.backgroundColor == AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconBox(
                  icon: item.icon,
                  size: boxSize,
                  iconSize: iconSize,
                  backgroundColor:
                      item.backgroundColor ?? AppColors.primaryLight,
                  iconColor: item.iconColor ?? AppColors.primary,
                  borderRadius: AppRadius.lgAll,
                  boxShadow: _isHighlighted
                      ? AppShadows.glow(AppColors.primary)
                      : null,
                ),
                if (item.badge != null) _buildBadge(item.badge!),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.label,
              style: labelStyle ?? AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(MenuBadge badge) {
    if (badge.isDot) {
      return Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: badge.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    }

    return Positioned(
      top: -7,
      right: -8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: badge.color,
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Text(
          badge.text!,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}

/// Grid menu responsif dengan jumlah kolom yang bisa diatur.
class MenuGrid extends StatelessWidget {
  const MenuGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.rowSpacing = AppSpacing.md,
    this.boxSize = AppSizes.serviceIconBox,
    this.iconSize = AppSizes.iconMd,
  });

  final List<MenuItemData> items;
  final int crossAxisCount;
  final double rowSpacing;
  final double boxSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final rowCount = (items.length / crossAxisCount).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        final start = row * crossAxisCount;
        return Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : rowSpacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(crossAxisCount, (col) {
              final index = start + col;
              return Expanded(
                child: index < items.length
                    ? MenuTile(
                        item: items[index],
                        boxSize: boxSize,
                        iconSize: iconSize,
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
        );
      }),
    );
  }
}
