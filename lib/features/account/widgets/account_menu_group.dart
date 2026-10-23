import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../account_navigation_helper.dart';

class AccountMenuSectionData {
  const AccountMenuSectionData({
    required this.title,
    required this.items,
  });

  final String title;
  final List<AccountMenuItemData> items;
}

class AccountMenuItemData {
  const AccountMenuItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? badgeText;
  final VoidCallback? onTap;
}

/// Kelompok daftar menu pada Halaman Akun.
class AccountMenuGroup extends StatelessWidget {
  const AccountMenuGroup({super.key, required this.section});

  final AccountMenuSectionData section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
          child: Text(
            section.title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.border),
                _AccountTile(item: section.items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.item});

  final AccountMenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap ??
          () {
            AccountNavigationHelper.openFeature(context, item.title);
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (item.badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  item.badgeText!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.iconMd,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
