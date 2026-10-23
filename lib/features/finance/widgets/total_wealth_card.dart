import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../services/service_navigation_helper.dart';

/// Kartu Total Kekayaan / Aset Bersih dengan rincian FinPay Cash, Tabungan, dan Investasi.
class TotalWealthCard extends StatefulWidget {
  const TotalWealthCard({
    super.key,
    required this.totalWealth,
    required this.cashBalance,
    required this.savingBalance,
    required this.investmentBalance,
    this.onStateChanged,
  });

  final int totalWealth;
  final int cashBalance;
  final int savingBalance;
  final int investmentBalance;
  final VoidCallback? onStateChanged;

  @override
  State<TotalWealthCard> createState() => _TotalWealthCardState();
}

class _TotalWealthCardState extends State<TotalWealthCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.primary),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Hide Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white70,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'TOTAL KEKAYAAN ASET',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _isBalanceVisible = !_isBalanceVisible);
                },
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: AppSizes.iconMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Total Wealth Value
          Text(
            _isBalanceVisible
                ? CurrencyFormatter.rupiah(widget.totalWealth)
                : CurrencyFormatter.hidden,
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Breakdown Row (Cash, Savings, Investment)
          Row(
            children: [
              Expanded(
                child: _AssetPill(
                  label: 'FinPay Cash',
                  amount: widget.cashBalance,
                  icon: Icons.account_balance_wallet_outlined,
                  isVisible: _isBalanceVisible,
                  onTap: () {
                    ServiceNavigationHelper.openService(
                      context,
                      'Isi Saldo',
                      onStateChanged: widget.onStateChanged,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _AssetPill(
                  label: 'Tabungan',
                  amount: widget.savingBalance,
                  icon: Icons.savings_outlined,
                  isVisible: _isBalanceVisible,
                  onTap: () {
                    ServiceNavigationHelper.openService(
                      context,
                      'Menabung',
                      onStateChanged: widget.onStateChanged,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _AssetPill(
                  label: 'Investasi',
                  amount: widget.investmentBalance,
                  icon: Icons.trending_up_rounded,
                  isVisible: _isBalanceVisible,
                  onTap: () {
                    ServiceNavigationHelper.openService(
                      context,
                      'Investasi',
                      onStateChanged: widget.onStateChanged,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetPill extends StatelessWidget {
  const _AssetPill({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isVisible,
    required this.onTap,
  });

  final String label;
  final int amount;
  final IconData icon;
  final bool isVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: AppRadius.mdAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  isVisible
                      ? CurrencyFormatter.rupiah(amount)
                      : 'Rp •••••••',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
