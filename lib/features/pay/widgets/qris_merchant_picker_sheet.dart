import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/qris_merchant.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Menampilkan daftar merchant uji coba sebagai simulasi hasil scan kamera.
/// Mengembalikan [QrisMerchant] yang dipilih, atau `null` bila ditutup.
Future<QrisMerchant?> showQrisMerchantPicker(BuildContext context) {
  return showModalBottomSheet<QrisMerchant>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _QrisMerchantPickerSheet(),
  );
}

class _QrisMerchantPickerSheet extends StatelessWidget {
  const _QrisMerchantPickerSheet();

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xs,
              ),
              child: Text('Pilih QRIS Merchant', style: AppTextStyles.h2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Simulasi hasil scan kamera. Setiap merchant memakai QRIS EMVCo '
                'dengan checksum yang divalidasi sebelum pembayaran.',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xl,
                ),
                itemCount: QrisMerchantCatalog.merchants.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final merchant = QrisMerchantCatalog.merchants[index];
                  return _MerchantTile(
                    merchant: merchant,
                    onTap: () => Navigator.pop(context, merchant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantTile extends StatelessWidget {
  const _MerchantTile({required this.merchant, required this.onTap});

  final QrisMerchant merchant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSizes.serviceIconBox,
                height: AppSizes.serviceIconBox,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(merchant.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${merchant.category} • ${merchant.city}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PillBadge(
                label: merchant.isDynamic
                    ? CurrencyFormatter.rupiah(merchant.suggestedAmount)
                    : 'Isi nominal',
                backgroundColor: merchant.isDynamic
                    ? AppColors.successLight
                    : AppColors.goldLight,
                foregroundColor: merchant.isDynamic
                    ? AppColors.success
                    : const Color(0xFF92400E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
