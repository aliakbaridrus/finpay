import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

/// Kartu saldo utama bergradasi biru.
/// Mendukung toggle sembunyikan saldo dan salin nomor akun.
class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.cashBalance,
    required this.savingBalance,
    required this.phoneNumber,
  });

  final int totalBalance;
  final int cashBalance;
  final int savingBalance;
  final String phoneNumber;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isHidden = false;

  String _format(int value) =>
      _isHidden ? CurrencyFormatter.hidden : CurrencyFormatter.rupiah(value);

  void _copyPhoneNumber() {
    Clipboard.setData(ClipboardData(text: widget.phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor akun disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          const SizedBox(height: AppSpacing.xl),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _format(widget.totalBalance),
              style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSubBalances(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'SALDO FINPAY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: () => setState(() => _isHidden = !_isHidden),
                borderRadius: AppRadius.pillAll,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    _isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: InkWell(
            onTap: _copyPhoneNumber,
            borderRadius: AppRadius.pillAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: AppRadius.pillAll,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.copy_rounded,
                    size: 12,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubBalances() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SubBalanceItem(
                label: 'FinPay Cash',
                value: _format(widget.cashBalance),
                dotColor: AppColors.mint,
              ),
            ),
            VerticalDivider(
              color: Colors.white.withValues(alpha: 0.25),
              thickness: 1,
              width: AppSpacing.xxl,
            ),
            Expanded(
              child: _SubBalanceItem(
                label: 'Tabungan',
                value: _format(widget.savingBalance),
                dotColor: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubBalanceItem extends StatelessWidget {
  const _SubBalanceItem({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm - 2),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
