import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';

/// Kartu "Arus Kas Ringkas": pemasukan vs pengeluaran bulan ini.
class CashFlowCard extends StatelessWidget {
  const CashFlowCard({
    super.key,
    required this.income,
    required this.expense,
    required this.incomeNote,
    required this.expenseNote,
  });

  final int income;
  final int expense;
  final String incomeNote;
  final String expenseNote;

  double get _incomeRatio {
    final total = income + expense;
    return total == 0 ? 0 : income / total;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _FlowTile(
                  label: 'Pemasukan',
                  amount: income,
                  note: incomeNote,
                  icon: Icons.south_west_rounded,
                  accentColor: AppColors.success,
                  noteColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FlowTile(
                  label: 'Pengeluaran',
                  amount: expense,
                  note: expenseNote,
                  icon: Icons.north_east_rounded,
                  accentColor: AppColors.danger,
                  noteColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          RoundedProgressBar(
            value: _incomeRatio,
            color: AppColors.success,
            remainderColor: AppColors.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const IconBox(
          icon: Icons.insights_rounded,
          size: 36,
          iconSize: AppSizes.iconSm + 2,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arus Kas Ringkas', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xxs),
              Text('Surplus finansial stabil', style: AppTextStyles.caption),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Detail',
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _FlowTile extends StatelessWidget {
  const _FlowTile({
    required this.label,
    required this.amount,
    required this.note,
    required this.icon,
    required this.accentColor,
    required this.noteColor,
  });

  final String label;
  final int amount;
  final String note;
  final IconData icon;
  final Color accentColor;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.rupiah(amount),
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            note,
            style: AppTextStyles.caption.copyWith(
              color: noteColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
