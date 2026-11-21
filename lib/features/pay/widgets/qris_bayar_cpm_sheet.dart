import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/services/account_service.dart';
import '../../../data/services/qris_service.dart';
import '../../../data/services/wallet_service.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../../shared/widgets/qris_code_card.dart';

/// Menampilkan kode QRIS Bayar (Customer Presented Mode / CPM) milik pengguna
/// setelah verifikasi PIN 6 digit berhasil dilakukan.
Future<void> showQrisBayarCpmSheet(
  BuildContext context, {
  VoidCallback? onSelectMerchant,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _QrisBayarCpmSheet(
      onSelectMerchant: onSelectMerchant,
    ),
  );
}

class _QrisBayarCpmSheet extends StatelessWidget {
  const _QrisBayarCpmSheet({this.onSelectMerchant});

  final VoidCallback? onSelectMerchant;

  @override
  Widget build(BuildContext context) {
    final cpmPayload = QrisService.instance.myQris(
      referenceLabel:
          'CPM-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kode QRIS Bayar (CPM)', style: AppTextStyles.h2),
                  const PillBadge(
                    label: 'PIN Terverifikasi',
                    leadingIcon: Icons.verified_user_rounded,
                    backgroundColor: AppColors.successLight,
                    foregroundColor: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tunjukkan kode QRIS ini ke scanner kasir untuk pembayaran instan.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ValueListenableBuilder<UserProfileModel>(
                valueListenable: AccountService.instance.userNotifier,
                builder: (context, user, _) {
                  return QrisCodeCard(
                    data: cpmPayload.encode(),
                    merchantName: user.fullName,
                    nmid: cpmPayload.nmid,
                    size: 190,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ValueListenableBuilder<WalletModel>(
                valueListenable: WalletService.instance.walletNotifier,
                builder: (context, wallet, _) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadius.lgAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sumber Dana Pembayaran',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                'FinPay Cash • ${CurrencyFormatter.rupiah(wallet.cashBalance)}',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (onSelectMerchant != null) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSelectMerchant?.call();
                    },
                    icon: const Icon(Icons.storefront_rounded, size: 18),
                    label: const Text(
                      'Pilih Merchant & Bayar Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
