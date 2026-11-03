import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/qris_model.dart';
import '../../../data/models/transaction_model.dart';

/// Menampilkan struk digital setelah pembayaran QRIS berhasil.
Future<void> showQrisReceipt(
  BuildContext context, {
  required TransactionModel transaction,
  required QrisPayload payload,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (context) => _QrisReceiptSheet(
      transaction: transaction,
      payload: payload,
    ),
  );
}

class _QrisReceiptSheet extends StatelessWidget {
  const _QrisReceiptSheet({required this.transaction, required this.payload});

  final TransactionModel transaction;
  final QrisPayload payload;

  @override
  Widget build(BuildContext context) {
    final paid = transaction.amount.abs();
    final amountBeforeFee = paid - transaction.adminFee;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Pembayaran QRIS Berhasil', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                CurrencyFormatter.rupiah(paid),
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Column(
                  children: [
                    _ReceiptRow('Merchant', payload.merchantName),
                    _ReceiptRow('Lokasi', payload.merchantCity),
                    _ReceiptRow('NMID', payload.nmid),
                    const _ReceiptRow('Metode', 'QRIS • FinPay Cash'),
                    _ReceiptRow('Waktu', transaction.dateTime),
                    _ReceiptRow('No. Referensi', transaction.referenceNumber),
                    const Divider(color: AppColors.border),
                    _ReceiptRow(
                      'Nominal',
                      CurrencyFormatter.rupiah(amountBeforeFee),
                    ),
                    _ReceiptRow(
                      'Biaya layanan',
                      transaction.adminFee == 0
                          ? 'Gratis'
                          : CurrencyFormatter.rupiah(transaction.adminFee),
                    ),
                    _ReceiptRow(
                      'Sisa saldo',
                      CurrencyFormatter.rupiah(DummyData.cashBalance),
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: transaction.referenceNumber),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nomor referensi disalin'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Salin Ref'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
