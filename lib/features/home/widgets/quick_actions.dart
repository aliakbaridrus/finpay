import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../data/models/menu_item_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/menu_grid.dart';

/// Baris aksi cepat: Top Up, Transfer, Tarik Tunai, QRIS Pay.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.items});

  final List<MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: MenuGrid(
        items: items,
        crossAxisCount: items.length,
        boxSize: AppSizes.quickActionBox,
        iconSize: AppSizes.iconLg,
      ),
    );
  }
}
