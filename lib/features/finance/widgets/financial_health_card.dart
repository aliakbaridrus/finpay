import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Kartu Analisis Kesehatan Finansial & Cash Flow.
class FinancialHealthCard extends StatelessWidget {
  const FinancialHealthCard({
    super.key,
    required this.income,
    required this.expense,
    required this.incomeGrowth,
    required this.expenseNote,
  });

  final int income;
  final int expense;
  final String incomeGrowth;
  final String expenseNote;

  int get surplus => income - expense;

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
              Row(
                children: [
                  const Icon(
                    Icons.donut_large_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Analisis Arus Kas', style: AppTextStyles.h3),
                ],
              ),
              const PillBadge(
                label: 'Surplus Stabil',
                backgroundColor: AppColors.mintLight,
                foregroundColor: Color(0xFF0F766E),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Pemasukan & Pengeluaran Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pemasukan',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.rupiah(income),
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        incomeGrowth,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pengeluaran',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.rupiah(expense),
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        expenseNote,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Net Surplus Indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.smAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa Surplus Keuangan',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.rupiah(surplus, withSign: true),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
