import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

/// App bar Beranda: logo FinPay, notifikasi, dan avatar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.hasUnreadNotification = true,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  final bool hasUnreadNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _FinPayLogo(),
        const Spacer(),
        _NotificationButton(
          hasUnread: hasUnreadNotification,
          onTap: onNotificationTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka Notifikasi Transaksi & Promo...'),
                  ),
                );
              },
        ),
        const SizedBox(width: AppSpacing.md),
        _Avatar(
          onTap: onAvatarTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka Profil Pengguna...'),
                  ),
                );
              },
        ),
      ],
    );
  }
}

class _FinPayLogo extends StatelessWidget {
  const _FinPayLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: AppColors.balanceGradient,
            borderRadius: AppRadius.smAll,
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: AppSizes.iconSm,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'FinPay',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasUnread, required this.onTap});

  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: AppSizes.iconLg,
          ),
          if (hasUnread)
            Positioned(
              top: 1,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.onTap});

  final VoidCallback onTap;
  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: AppShadows.card,
          color: AppColors.primaryLight,
        ),
        child: const Icon(Icons.person_rounded, color: AppColors.primary),
      ),
    );
  }
}
