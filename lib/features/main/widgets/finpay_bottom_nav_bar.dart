import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class NavItemData {
  const NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Bottom navigation dengan tombol tengah (Bayar) yang menonjol.
///
/// [items] harus berjumlah ganjil; item di tengah dirender sebagai
/// tombol bulat besar.
class FinPayBottomNavBar extends StatelessWidget {
  const FinPayBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  int get _centerIndex => items.length ~/ 2;

  @override
  Widget build(BuildContext context) {
    assert(items.length.isOdd, 'Jumlah item harus ganjil');
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: AppSizes.bottomNavHeight,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: index == _centerIndex
                  ? _CenterNavButton(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onTap(index),
                    )
                  : _NavButton(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onTap(index),
                    ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? item.activeIcon : item.icon,
            color: color,
            size: AppSizes.iconLg - 2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  const _CenterNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _size = AppSizes.bottomNavCenterButton;

  /// Seberapa jauh tombol menonjol di atas bar.
  static const double _lift = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Tombol bulat yang menonjol dari bar.
        Positioned(
          top: -_lift,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                gradient: AppColors.balanceGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                boxShadow: AppShadows.glow(AppColors.primary),
              ),
              child: Icon(item.icon, color: Colors.white, size: AppSizes.iconLg),
            ),
          ),
        ),
        Positioned(
          bottom: AppSpacing.sm + 2,
          child: Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
