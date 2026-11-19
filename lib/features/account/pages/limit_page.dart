import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/account_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/rounded_progress_bar.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';
import 'contact_cs_page.dart';

/// Limit Transaksi terintegrasi [AccountService] & koleksi `users` (Bagian Tugas Pidi).
class TransactionLimitPage extends StatefulWidget {
  const TransactionLimitPage({super.key});

  @override
  State<TransactionLimitPage> createState() => _TransactionLimitPageState();
}

class _TransactionLimitPageState extends State<TransactionLimitPage> {
  static const double _min = 1000000;

  late double _limit;

  @override
  void initState() {
    super.initState();
    _limit = AccountService.instance.currentUser.dailyLimit.toDouble();
  }

  Future<void> _save() async {
    try {
      await AccountService.instance.updateDailyLimit(_limit.round());
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Limit transfer harian diubah ke ${CurrencyFormatter.rupiah(_limit)} & disimpan ke Firebase',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfileModel>(
      valueListenable: AccountService.instance.userNotifier,
      builder: (context, user, _) {
        final maxLimit = user.maxDailyLimit.toDouble();
        final savedLimit = user.dailyLimit.toDouble();
        final usedToday = AccountService.instance.usedTodayAmount;
        final remaining = (savedLimit - usedToday).clamp(0, savedLimit);
        final usedRatio =
            savedLimit > 0 ? (usedToday / savedLimit).clamp(0.0, 1.0) : 0.0;
        final changed = (_limit - savedLimit).abs() > 1;

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
                onPressed: changed ? _save : null,
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
                    color: changed ? Colors.white : AppColors.textTertiary,
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
                    CurrencyFormatter.rupiah(usedToday),
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
                        'Limit ${CurrencyFormatter.rupiah(savedLimit)}',
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
                    value: _limit.clamp(_min, maxLimit),
                    min: _min,
                    max: maxLimit,
                    divisions: 49,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryLight,
                    label: CurrencyFormatter.rupiah(_limit),
                    onChanged: (v) => setState(() => _limit = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.rupiah(_min),
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        CurrencyFormatter.rupiah(maxLimit),
                        style: AppTextStyles.caption,
                      ),
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
                children: [
                  const _LimitRow(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Top Up',
                    value: 'Rp 20.000.000 / transaksi',
                  ),
                  const _LimitDivider(),
                  const _LimitRow(
                    icon: Icons.payments_outlined,
                    title: 'Tarik Tunai',
                    value: 'Rp 5.000.000 / hari',
                  ),
                  const _LimitDivider(),
                  const _LimitRow(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'QRIS Pay',
                    value: 'Rp 10.000.000 / transaksi',
                  ),
                  const _LimitDivider(),
                  _LimitRow(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Transfer Antar Bank',
                    value: '${CurrencyFormatter.rupiah(savedLimit)} / hari',
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
      },
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
