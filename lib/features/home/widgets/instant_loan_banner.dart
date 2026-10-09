import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Banner promosi pinjaman instan (kartu gelap).
class InstantLoanBanner extends StatelessWidget {
  const InstantLoanBanner({
    super.key,
    required this.maxAmount,
    required this.minInstallment,
    required this.interestLabel,
    this.onApplyTap,
  });

  final int maxAmount;
  final int minInstallment;
  final String interestLabel;
  final VoidCallback? onApplyTap;

  static final Color _mutedWhite = Colors.white.withValues(alpha: 0.7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.loanGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.navy),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: PillBadge(
                  label: 'FinPay Instan • Izin OJK',
                  leadingIcon: Icons.verified_user_rounded,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: AppColors.mint,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                interestLabel,
                style: AppTextStyles.caption
                    .copyWith(color: _mutedWhite, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Dana Tunai s.d ${CurrencyFormatter.rupiah(maxAmount)}',
              style: AppTextStyles.h1.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Persetujuan instan 5 menit langsung masuk ke Saldo FinPay.',
            style: AppTextStyles.bodySmall.copyWith(color: _mutedWhite),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildInstallmentInfo()),
              const SizedBox(width: AppSpacing.md),
              _buildApplyButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cicilan fleksibel mulai',
          style: AppTextStyles.caption.copyWith(color: _mutedWhite, fontSize: 10),
        ),
        const SizedBox(height: AppSpacing.xxs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: CurrencyFormatter.rupiah(minInstallment),
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                TextSpan(
                  text: ' /bulan',
                  style: AppTextStyles.caption.copyWith(color: _mutedWhite),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: onApplyTap ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      child: Text(
        'Ajukan Sekarang',
        style: AppTextStyles.label.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
