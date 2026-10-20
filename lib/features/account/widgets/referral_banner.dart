import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Banner ajakan referral (kartu gelap, senada dengan banner pinjaman).
/// Tap kode atau tombol "Salin" untuk menyalin kode ke clipboard.
class ReferralBanner extends StatelessWidget {
  const ReferralBanner({
    super.key,
    required this.code,
    required this.bonusPoints,
  });

  final String code;
  final int bonusPoints;

  static final Color _mutedWhite = Colors.white.withValues(alpha: 0.7);

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode referral disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.navy),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.loanGradient),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PillBadge(
                      label: 'Program Referral',
                      leadingIcon: Icons.redeem_rounded,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: AppColors.mint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Ajak teman, dapat $bonusPoints FinPoin',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bonus untukmu dan temanmu setelah transaksi pertama.',
                      style: AppTextStyles.bodySmall.copyWith(color: _mutedWhite),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(child: _buildCodeBox(context)),
                        const SizedBox(width: AppSpacing.md),
                        _buildCopyButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(BuildContext context) {
    return InkWell(
      onTap: () => _copy(context),
      borderRadius: AppRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  code,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.copy_rounded, size: 16, color: _mutedWhite),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _copy(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      child: Text(
        'Salin',
        style: AppTextStyles.label.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
