import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/icon_box.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh: Detail Resi Transaksi FinPay.
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncoming;
    final amountColor = isIncome ? AppColors.success : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Transaksi', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyiapkan resi transaksi...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            // Main Status & Amount Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  IconBox(
                    icon: transaction.icon,
                    size: 64,
                    iconSize: 32,
                    backgroundColor: isIncome ? AppColors.mintLight : AppColors.primaryLight,
                    iconColor: isIncome ? const Color(0xFF0F766E) : AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    transaction.title,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PillBadge(
                    label: '● ${transaction.status}',
                    backgroundColor: AppColors.successLight,
                    foregroundColor: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    CurrencyFormatter.rupiah(transaction.amount, withSign: true),
                    style: AppTextStyles.displayLarge.copyWith(
                      color: amountColor,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Detail Rincian Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rincian Transaksi', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.md),

                  _DetailItemRow(
                    label: 'Waktu Transaksi',
                    value: '${transaction.dateGroup}, ${transaction.dateTime.split(', ').last}',
                  ),
                  _DetailItemRow(label: 'Kategori', value: transaction.category),
                  _DetailItemRow(label: 'Metode Pembayaran', value: transaction.channel),
                  _DetailItemRow(
                    label: 'Nomor Referensi',
                    value: transaction.referenceNumber,
                    isCopyable: true,
                    onCopyTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor referensi berhasil disalin!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _DetailItemRow(
                    label: 'Biaya Admin',
                    value: transaction.adminFee == 0
                        ? 'Gratis'
                        : CurrencyFormatter.rupiah(transaction.adminFee),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    _DetailItemRow(label: 'Catatan', value: transaction.note!),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mengunduh bukti resi Struk PDF...')),
                  );
                },
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                label: const Text('Unduh Resi PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka Pusat Bantuan CS...')),
                  );
                },
                icon: const Icon(Icons.headset_mic_outlined, color: AppColors.primary),
                label: const Text('Bantuan / Laporkan Kendala', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  const _DetailItemRow({
    required this.label,
    required this.value,
    this.isCopyable = false,
    this.onCopyTap,
  });

  final String label;
  final String value;
  final bool isCopyable;
  final VoidCallback? onCopyTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onCopyTap,
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
