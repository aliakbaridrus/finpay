import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';

/// Kartu progres target menabung.
class SavingGoalCard extends StatelessWidget {
  const SavingGoalCard({
    super.key,
    required this.title,
    required this.monthlyDebit,
    required this.current,
    required this.target,
    required this.eta,
    this.onDepositTap,
  });

  final String title;
  final int monthlyDebit;
  final int current;
  final int target;
  final String eta;
  final VoidCallback? onDepositTap;

  double get _progress => target == 0 ? 0 : current / target;
  int get _percent => (_progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildAmountRow(),
          const SizedBox(height: AppSpacing.sm),
          RoundedProgressBar(value: _progress),
          const SizedBox(height: AppSpacing.md),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconBox(
          icon: Icons.flight_takeoff_rounded,
          size: 36,
          iconSize: AppSizes.iconSm + 2,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Auto-debet aktif • ${CurrencyFormatter.rupiah(monthlyDebit)}/bln',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PillBadge(
          label: '$_percent%',
          backgroundColor: AppColors.successLight,
          foregroundColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildAmountRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.rupiah(current),
              style: AppTextStyles.displayMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Target: ${CurrencyFormatter.rupiah(target)}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(
          Icons.trending_up_rounded,
          size: 14,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Estimasi tercapai: $eta',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Material(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.smAll,
          child: InkWell(
            onTap: onDepositTap ?? () {},
            borderRadius: AppRadius.smAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              child: Text(
                '+ Setor Dana',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
