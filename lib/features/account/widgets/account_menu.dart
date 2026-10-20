import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';

/// Warna aksen untuk ikon menu, supaya tiap grup punya identitas sendiri.
enum AccountTone { blue, mint, gold, red }

extension _AccountToneColors on AccountTone {
  Color get background => switch (this) {
        AccountTone.blue => AppColors.primaryLight,
        AccountTone.mint => AppColors.mintLight,
        AccountTone.gold => AppColors.goldLight,
        AccountTone.red => AppColors.dangerLight,
      };

  Color get foreground => switch (this) {
        AccountTone.blue => AppColors.primary,
        AccountTone.mint => const Color(0xFF0F766E),
        AccountTone.gold => const Color(0xFF92400E),
        AccountTone.red => AppColors.danger,
      };
}

/// Judul section + kartu putih berisi daftar menu.
/// Garis pemisah antar menu disisipkan otomatis.
class MenuSection extends StatelessWidget {
  const MenuSection({
    super.key,
    required this.title,
    required this.children,
    this.tone = AccountTone.blue,
  });

  final String title;
  final List<MenuTile> children;

  /// Warna ikon untuk semua menu di grup ini.
  final AccountTone tone;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i].withTone(tone));
      if (i != children.length - 1) {
        items.add(const Divider(
          height: 1,
          // padding kiri + lebar ikon + jarak: garis mulai tepat di bawah label.
          indent: AppSpacing.lg + AppSizes.transactionIconBox + AppSpacing.md,
          color: AppColors.border,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(children: items),
        ),
      ],
    );
  }
}

/// Satu baris menu: kotak ikon, label (+ subjudul), lalu badge / nilai /
/// panah / switch di kanan. Dibikin sekali, dipakai berkali-kali.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.badge,
    this.trailing,
    this.onTap,
    this.tone,
  });

  final IconData icon;
  final String label;

  /// Teks kecil di bawah label.
  final String? subtitle;

  /// Teks kecil di kanan, mis. "Indonesia".
  final String? value;

  /// Badge kecil di kanan, mis. "Terverifikasi".
  final Widget? badge;

  /// Kalau diisi (mis. Switch), menggantikan panah.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Biasanya diisi otomatis oleh [MenuSection].
  final AccountTone? tone;

  MenuTile withTone(AccountTone defaultTone) => MenuTile(
        key: key,
        icon: icon,
        label: label,
        subtitle: subtitle,
        value: value,
        badge: badge,
        trailing: trailing,
        onTap: onTap,
        tone: tone ?? defaultTone,
      );

  @override
  Widget build(BuildContext context) {
    final effectiveTone = tone ?? AccountTone.blue;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            IconBox(
              icon: icon,
              size: AppSizes.transactionIconBox,
              backgroundColor: effectiveTone.background,
              iconColor: effectiveTone.foreground,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null) ...[
              badge!,
              const SizedBox(width: AppSpacing.xs),
            ],
            if (value != null) ...[
              Text(value!, style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.xs),
            ],
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}
