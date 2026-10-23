import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../services/service_navigation_helper.dart';

/// Kartu Ringkasan Portofolio Investasi di Halaman Keuangan.
class InvestmentPortfolioCard extends StatelessWidget {
  const InvestmentPortfolioCard({
    super.key,
    required this.investmentBalance,
    required this.investmentReturn,
    this.onStateChanged,
  });

  final int investmentBalance;
  final int investmentReturn;
  final VoidCallback? onStateChanged;

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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.mintLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: AppSizes.iconSm,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Portofolio Investasi', style: AppTextStyles.h3),
                ],
              ),
              const PillBadge(
                label: 'Risiko Rendah',
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Balance & Profit Return
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.rupiah(investmentBalance),
                style: AppTextStyles.h1.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_drop_up_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  Text(
                    '${CurrencyFormatter.rupiah(investmentReturn, withSign: true)} (+4.5%)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reksa Dana Pasar Uang • FinPay Invest',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tombol Aksi Investasi Full Page Navigation
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ServiceNavigationHelper.openService(
                    context,
                    'Investasi',
                    onStateChanged: onStateChanged,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillAll,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                  ),
                  child: const Text('Detail Portofolio'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ServiceNavigationHelper.openService(
                    context,
                    'Investasi',
                    onStateChanged: onStateChanged,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillAll,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                  ),
                  child: const Text('Top Up Investasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
