import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';

/// Kartu profil utama: avatar inisial, status verifikasi, statistik singkat,
/// dan progress menuju level membership berikutnya.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.userName,
    required this.email,
    required this.membership,
    required this.points,
    required this.memberSince,
    required this.transactionCount,
    required this.nextTierName,
    required this.nextTierPoints,
    this.onEditTap,
  });

  final String userName;
  final String email;
  final String membership;
  final int points;
  final String memberSince;
  final int transactionCount;
  final String nextTierName;
  final int nextTierPoints;
  final VoidCallback? onEditTap;

  /// "Reza Pratama" -> "RP"
  String get _initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final second = parts.length > 1 ? parts[1][0] : '';
    return (parts.first[0] + second).toUpperCase();
  }

  /// 1420 -> "1.420"
  static String _thousands(int value) => value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );

  @override
  Widget build(BuildContext context) {
    final remaining = nextTierPoints > points ? nextTierPoints - points : 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.primary),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.balanceGradient),
          child: Stack(
            children: [
              // Lingkaran dekoratif supaya kartu terasa lebih hidup.
              const Positioned(
                top: -40,
                right: -30,
                child: _GlowCircle(size: 150, alpha: 0.08),
              ),
              const Positioned(
                bottom: -60,
                left: -40,
                child: _GlowCircle(size: 140, alpha: 0.06),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentity(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStatsPanel(remaining),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentity() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs + 2,
                runSpacing: AppSpacing.xs,
                children: [
                  PillBadge(
                    label: membership,
                    leadingIcon: Icons.workspace_premium_rounded,
                    backgroundColor: AppColors.goldLight,
                    foregroundColor: const Color(0xFF92400E),
                  ),
                  PillBadge(
                    label: 'Terverifikasi',
                    leadingIcon: Icons.verified_rounded,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    foregroundColor: AppColors.mint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Text(
                _initials,
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ),
          // Tombol edit kecil di pojok avatar.
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: onEditTap ?? () {},
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryDark, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(int remaining) {
    final progress = nextTierPoints == 0 ? 1.0 : points / nextTierPoints;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _Stat(value: _thousands(points), label: 'FinPoin'),
                _divider(),
                _Stat(value: '$transactionCount', label: 'Transaksi bln ini'),
                _divider(),
                _Stat(value: memberSince, label: 'Member sejak'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Menuju $nextTierName',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Text(
                '${_thousands(remaining)} poin lagi',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RoundedProgressBar(
            value: progress,
            height: 6,
            color: AppColors.mint,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _divider() => VerticalDivider(
        color: Colors.white.withValues(alpha: 0.25),
        thickness: 1,
        width: AppSpacing.lg,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}
