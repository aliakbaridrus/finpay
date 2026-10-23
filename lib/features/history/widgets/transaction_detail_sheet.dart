import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Modal bottom sheet yang menampilkan detail lengkap transaksi saat item ditap.
class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({super.key, required this.transaction});

  final TransactionModel transaction;

  static void show(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncoming;
    final amountColor = isIncome ? AppColors.success : AppColors.textPrimary;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Icon Status & Info Utama
          IconBox(
            icon: transaction.icon,
            size: 56,
            iconSize: 28,
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

          // Nominal Transaksi
          Text(
            CurrencyFormatter.rupiah(transaction.amount, withSign: true),
            style: AppTextStyles.displayLarge.copyWith(
              color: amountColor,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Rincian Detail Transaksi
          _DetailRow(
            label: 'Waktu Transaksi',
            value: '${transaction.dateGroup}, ${transaction.dateTime.split(', ').last}',
          ),
          _DetailRow(label: 'Kategori', value: transaction.category),
          _DetailRow(label: 'Metode / Kanal', value: transaction.channel),
          _DetailRow(
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
          _DetailRow(
            label: 'Biaya Admin',
            value: transaction.adminFee == 0
                ? 'Gratis'
                : CurrencyFormatter.rupiah(transaction.adminFee),
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            _DetailRow(label: 'Catatan', value: transaction.note!),

          const SizedBox(height: AppSpacing.xl),

          // Tombol Aksi (Bagikan Resi & Tutup)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menyiapkan resi transaksi...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Bagikan Resi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillAll,
                    ),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
