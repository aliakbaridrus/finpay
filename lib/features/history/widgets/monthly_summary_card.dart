import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';

/// Kartu ringkasan Pemasukan & Pengeluaran bulanan di Riwayat Transaksi.
class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.periodLabel,
  });

  final int totalIncome;
  final int totalExpense;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final totalFlow = (totalIncome + totalExpense).toDouble();
    final incomeRatio = totalFlow > 0 ? totalIncome / totalFlow : 0.5;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.donut_large_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Ringkasan $periodLabel',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Arus Kas',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Pemasukan & Pengeluaran Side by Side
          Row(
            children: [
              Expanded(
                child: _FlowItem(
                  label: 'Pemasukan',
                  amount: totalIncome,
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              Expanded(
                child: _FlowItem(
                  label: 'Pengeluaran',
                  amount: totalExpense,
                  color: AppColors.danger,
                  backgroundColor: AppColors.dangerLight,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Ratio Bar
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 100).round(),
                    child: Container(color: AppColors.success),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: ((1 - incomeRatio) * 100).round(),
                    child: Container(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowItem extends StatelessWidget {
  const _FlowItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  final String label;
  final int amount;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xxs),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyFormatter.rupiah(amount),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
