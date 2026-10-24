import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../data/models/menu_item_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/menu_grid.dart';
import '../../../shared/widgets/section_header.dart';

/// Section "Layanan Keuangan" berisi grid 3 kolom (6 layanan).
class FinancialServicesSection extends StatelessWidget {
  const FinancialServicesSection({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<MenuItemData> items;
  final void Function(MenuItemData item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Layanan Keuangan',
          actionLabel: 'Lihat Semua',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.lg,
          ),
          child: MenuGrid(
            items: items,
            crossAxisCount: 3,
            rowSpacing: AppSpacing.lg,
            onItemTap: onItemTap,
          ),
        ),
      ],
    );
  }
}
