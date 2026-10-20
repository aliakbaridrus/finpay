import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';
import '../account_data.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';
import 'contact_cs_page.dart';

/// Limit Transaksi: pemakaian hari ini, atur limit transfer harian
/// dengan slider, dan daftar limit per jenis transaksi.
class TransactionLimitPage extends StatefulWidget {
  const TransactionLimitPage({super.key});

  @override
  State<TransactionLimitPage> createState() => _TransactionLimitPageState();
}

class _TransactionLimitPageState extends State<TransactionLimitPage> {
  static const double _min = 1000000;
  static const int _usedToday = 3650000;

  final double _max = AccountDummy.dailyLimit.toDouble();
  double _savedLimit = 25000000;
  double _limit = 25000000;

  bool get _changed => (_limit - _savedLimit).abs() > 1;

  void _save() {
    setState(() => _savedLimit = _limit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Limit transfer harian diubah ke ${CurrencyFormatter.rupiah(_limit)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _savedLimit - _usedToday;
    final usedRatio = _usedToday / _savedLimit;

    return SubPageScaffold(
      title: 'Limit Transaksi',
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _changed ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textTertiary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            ),
            child: Text(
              'Simpan Perubahan',
              style: AppTextStyles.bodyLarge.copyWith(
                color: _changed ? Colors.white : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
      children: [
        // ---------- Pemakaian hari ini ----------
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terpakai hari ini', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                CurrencyFormatter.rupiah(_usedToday),
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              RoundedProgressBar(value: usedRatio, height: 8),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sisa ${CurrencyFormatter.rupiah(remaining)}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                  Text(
                    'Limit ${CurrencyFormatter.rupiah(_savedLimit)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),

        // ---------- Atur limit transfer ----------
        Text('Atur Limit Transfer Harian', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyFormatter.rupiah(_limit),
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Geser untuk mengatur batas transfer per hari.',
                style: AppTextStyles.bodySmall,
              ),
              Slider(
                value: _limit,
                min: _min,
                max: _max,
                divisions: 49,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primaryLight,
                label: CurrencyFormatter.rupiah(_limit),
                onChanged: (v) => setState(() => _limit = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CurrencyFormatter.rupiah(_min),
                      style: AppTextStyles.caption),
                  Text(CurrencyFormatter.rupiah(_max),
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),

        // ---------- Limit per jenis transaksi ----------
        Text('Limit per Jenis Transaksi', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: const [
              _LimitRow(
                icon: Icons.add_circle_outline_rounded,
                title: 'Top Up',
                value: 'Rp 20.000.000 / transaksi',
              ),
              _LimitDivider(),
              _LimitRow(
                icon: Icons.payments_outlined,
                title: 'Tarik Tunai',
                value: 'Rp 5.000.000 / hari',
              ),
              _LimitDivider(),
              _LimitRow(
                icon: Icons.qr_code_scanner_rounded,
                title: 'QRIS Pay',
                value: 'Rp 10.000.000 / transaksi',
              ),
              _LimitDivider(),
              _LimitRow(
                icon: Icons.swap_horiz_rounded,
                title: 'Transfer Antar Bank',
                value: 'Rp 50.000.000 / hari',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        InfoNote(
          icon: Icons.trending_up_rounded,
          title: 'Butuh limit lebih besar?',
          text: 'Limit di atas Rp 50 juta per hari perlu pengajuan dan '
              'verifikasi tambahan dari tim FinPay.',
          actionLabel: 'Ajukan lewat CS',
          onActionTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ContactCsPage()),
          ),
        ),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconBox(icon: icon, size: AppSizes.transactionIconBox),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitDivider extends StatelessWidget {
  const _LimitDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: AppSpacing.lg + AppSizes.transactionIconBox + AppSpacing.md,
      color: AppColors.border,
    );
  }
}
