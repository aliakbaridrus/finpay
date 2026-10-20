import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Kartu skor keamanan akun dengan ring progress yang beranimasi.
///
/// Skor dihitung di halaman induk; kartu ini hanya menampilkan hasilnya
/// dan memberi tombol aksi cepat untuk menaikkan skor.
class SecurityScoreCard extends StatelessWidget {
  const SecurityScoreCard({
    super.key,
    required this.score,
    required this.hint,
    this.actionLabel,
    this.onActionTap,
  });

  /// 0 - 100
  final int score;

  /// Saran singkat untuk menaikkan skor.
  final String hint;

  /// Teks tombol aksi. Jika null, tombol tidak ditampilkan.
  final String? actionLabel;
  final VoidCallback? onActionTap;

  _Level get _level {
    if (score >= 90) {
      return const _Level(
        label: 'Kuat',
        color: AppColors.success,
        background: AppColors.successLight,
      );
    }
    if (score >= 70) {
      return const _Level(
        label: 'Cukup',
        color: Color(0xFFD97706),
        background: AppColors.goldLight,
      );
    }
    return const _Level(
      label: 'Lemah',
      color: AppColors.danger,
      background: AppColors.dangerLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRing(level),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Keamanan Akun', style: AppTextStyles.h3),
                    ),
                    PillBadge(
                      label: level.label,
                      backgroundColor: level.background,
                      foregroundColor: level.color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hint,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: onActionTap,
                    borderRadius: AppRadius.smAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel!,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: AppSizes.iconSm,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(_Level level) {
    return SizedBox(
      width: 68,
      height: 68,
      // TweenAnimationBuilder otomatis menganimasikan nilai dari posisi
      // sebelumnya ke skor baru setiap kali `score` berubah.
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: AlwaysStoppedAnimation<Color>(level.color),
                ),
              ),
              Text(
                '${(value * 100).round()}',
                style: AppTextStyles.h2.copyWith(color: level.color),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Level {
  const _Level({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;
}
