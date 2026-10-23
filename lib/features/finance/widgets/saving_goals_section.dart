import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';
import '../../../shared/widgets/section_header.dart';
import '../../services/service_navigation_helper.dart';

/// Section Target Menabung & Impian di Halaman Keuangan.
class SavingGoalsSection extends StatelessWidget {
  const SavingGoalsSection({super.key, this.onStateChanged});

  final VoidCallback? onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Target Menabung',
          actionLabel: '+ Tambah Target',
          showChevron: false,
          onActionTap: () => ServiceNavigationHelper.openService(
            context,
            'Menabung',
            onStateChanged: onStateChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Goal Card 1: Liburan ke Jepang
        _GoalCard(
          title: 'Liburan ke Jepang ✈️',
          category: 'Impian',
          monthlyDebit: 500000,
          currentAmount: 7500000,
          targetAmount: 15000000,
          eta: 'Mei 2025',
          progressColor: AppColors.primary,
          onSetorTap: () => ServiceNavigationHelper.openService(
            context,
            'Menabung',
            onStateChanged: onStateChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Goal Card 2: Dana Darurat
        _GoalCard(
          title: 'Dana Darurat 6 Bulan 🛡️',
          category: 'Keamanan',
          monthlyDebit: 1000000,
          currentAmount: 8000000,
          targetAmount: 10000000,
          eta: 'Desember 2024',
          progressColor: AppColors.mint,
          onSetorTap: () => ServiceNavigationHelper.openService(
            context,
            'Menabung',
            onStateChanged: onStateChanged,
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.category,
    required this.monthlyDebit,
    required this.currentAmount,
    required this.targetAmount,
    required this.eta,
    required this.progressColor,
    this.onSetorTap,
  });

  final String title;
  final String category;
  final int monthlyDebit;
  final int currentAmount;
  final int targetAmount;
  final String eta;
  final Color progressColor;
  final VoidCallback? onSetorTap;

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get percentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PillBadge(
                label: '$percentage%',
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Auto-debet aktif • ${CurrencyFormatter.rupiah(monthlyDebit)}/bln',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar
          RoundedProgressBar(
            value: progress,
            color: progressColor,
            height: 8,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Nominal & Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.rupiah(currentAmount),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Target: ${CurrencyFormatter.rupiah(targetAmount)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // Footer Action & Estimasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estimasi: $eta',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
              InkWell(
                onTap: onSetorTap,
                borderRadius: AppRadius.pillAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    '+ Setor Dana',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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
