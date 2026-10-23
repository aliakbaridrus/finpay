import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../transaction_detail_page.dart';

/// Daftar transaksi yang dikelompokkan berdasarkan tanggal/kelompok hari.
class TransactionListGroup extends StatelessWidget {
  const TransactionListGroup({
    super.key,
    required this.transactions,
  });

  final List<TransactionModel> transactions;

  Map<String, List<TransactionModel>> _groupTransactions() {
    final Map<String, List<TransactionModel>> map = {};
    for (final trx in transactions) {
      final key = trx.dateGroup;
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(trx);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupTransactions();

    if (grouped.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      children: [
        for (final entry in grouped.entries) ...[
          _DateGroupHeader(title: entry.key),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                for (var i = 0; i < entry.value.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.border),
                  _HistoryTile(
                    transaction: entry.value[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => TransactionDetailPage(
                            transaction: entry.value[i],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction, required this.onTap});

  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncoming;
    final amountColor = isIncome ? AppColors.success : AppColors.textPrimary;

    // Menentukan skema warna IconBox sesuai jenis transaksi
    final (bgColor, iconColor) = switch (transaction.type) {
      TransactionType.income => (AppColors.mintLight, const Color(0xFF0F766E)),
      TransactionType.expense => (AppColors.primaryLight, AppColors.primary),
      TransactionType.saving => (AppColors.goldLight, const Color(0xFFB45309)),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            IconBox(
              icon: transaction.icon,
              size: AppSizes.transactionIconBox,
              iconSize: AppSizes.iconMd,
              backgroundColor: bgColor,
              iconColor: iconColor,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    transaction.subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.rupiah(transaction.amount, withSign: true),
                  style: AppTextStyles.body.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      transaction.status,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tidak Ada Transaksi',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tidak ada riwayat transaksi yang cocok dengan pencarian atau filter yang kamu pilih.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
