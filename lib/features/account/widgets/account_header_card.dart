import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../pages/profile_detail_page.dart';

/// Kartu Profil User Utama di Halaman Akun.
class AccountHeaderCard extends StatelessWidget {
  const AccountHeaderCard({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.membership,
    required this.points,
    this.onEditProfileTap,
  });

  final String userName;
  final String phoneNumber;
  final String membership;
  final int points;
  final VoidCallback? onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.balanceGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: AppShadows.card,
                    ),
                    child: const Center(
                      child: Text(
                        'RP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Name & Phone Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: AppTextStyles.h2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Text(
                          phoneNumber,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nomor HP berhasil disalin!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Badges: Membership & Points
          Row(
            children: [
              PillBadge(
                label: '👑 $membership',
                backgroundColor: AppColors.goldLight,
                foregroundColor: const Color(0xFFB45309),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PillBadge(
                label: '⭐ $points FinPoin',
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEditProfileTap ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ProfileDetailPage(),
                        ),
                      );
                    },
                borderRadius: AppRadius.pillAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    'Edit Profil',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
