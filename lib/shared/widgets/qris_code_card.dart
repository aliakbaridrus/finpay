import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';

/// Kartu QRIS: menampilkan QR yang bisa dipindai beserta identitas merchant.
class QrisCodeCard extends StatelessWidget {
  const QrisCodeCard({
    super.key,
    required this.data,
    required this.merchantName,
    required this.nmid,
    this.amount,
    this.size = 220,
  });

  /// String QRIS lengkap hasil `QrisPayload.encode()`.
  final String data;
  final String merchantName;
  final String nmid;

  /// Jika terisi, ditampilkan sebagai nominal terkunci (QRIS dinamis).
  final int? amount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QRIS',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'GPN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            merchantName,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 2),
          Text(
            'NMID: $nmid',
            style: AppTextStyles.caption.copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          QrImageView(
            data: data,
            size: size,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textPrimary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
          if (amount != null && amount! > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                'Nominal terkunci ${CurrencyFormatter.rupiah(amount!)}',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dapat dipindai dari aplikasi bank & e-wallet berlogo QRIS',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
