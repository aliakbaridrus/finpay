import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/account_service.dart';
import '../../../shared/dialogs/widgets/finpay_receipt_dialog.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Menampilkan Bottom Sheet Tukar FinPoin menjadi Saldo FinPay Cash (1 FinPoin = Rp 100).
Future<void> showRedeemPoinSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const RedeemPoinSheet(),
  );
}

class RedeemPoinSheet extends StatefulWidget {
  const RedeemPoinSheet({super.key});

  @override
  State<RedeemPoinSheet> createState() => _RedeemPoinSheetState();
}

class _RedeemPoinSheetState extends State<RedeemPoinSheet> {
  final TextEditingController _pointsController = TextEditingController(
    text: '500',
  );
  bool _isProcessing = false;

  static const List<int> _quickOptions = [100, 250, 500, 1000];

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  int get _enteredPoints =>
      int.tryParse(_pointsController.text.replaceAll('.', '').trim()) ?? 0;

  int get _estimatedCash => _enteredPoints * 100;

  Future<void> _submitRedeem() async {
    if (_isProcessing) return;
    final points = _enteredPoints;
    final timeFormatted = TimeOfDay.now().format(context);
    final nav = Navigator.of(context);
    final rootContext = nav.context;

    setState(() => _isProcessing = true);
    try {
      final res = await AccountService.instance.redeemFinPoin(
        pointsToRedeem: points,
        timeFormatted: timeFormatted,
      );
      if (!mounted) return;
      nav.pop();
      if (!rootContext.mounted) return;
      await showFinPayReceiptDialog(
        rootContext,
        title: 'Tukar FinPoin Berhasil! 🎁',
        amountText: CurrencyFormatter.rupiah(res.cashAdded, withSign: true),
        amountColor: AppColors.success,
        referenceNumber: res.transaction.referenceNumber,
        details: [
          {'label': 'No. Referensi', 'value': res.transaction.referenceNumber},
          {'label': 'FinPoin Ditukar', 'value': '$points FinPoin'},
          {'label': 'Nilai Konversi', 'value': '1 FinPoin = Rp 100'},
          {
            'label': 'Sisa FinPoin',
            'value': '${AccountService.instance.currentUser.finPoin} FinPoin',
          },
          {
            'label': 'Saldo Cash Sekarang',
            'value': CurrencyFormatter.rupiah(DummyData.cashBalance),
          },
        ],
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tukar FinPoin ke Saldo Cash', style: AppTextStyles.h2),
                    PillBadge(
                      label: '${user.finPoin} Poin Aktif',
                      leadingIcon: Icons.workspace_premium_rounded,
                      backgroundColor: AppColors.goldLight,
                      foregroundColor: const Color(0xFF92400E),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '1 FinPoin bernilai Rp 100 Saldo FinPay Cash (Min. 100 Poin). Dapatkan +500 FinPoin setiap mengajak teman mendaftar pakai kode referralmu!',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final opt in _quickOptions)
                      ChoiceChip(
                        label: Text('$opt Poin'),
                        selected: _enteredPoints == opt,
                        onSelected: (_) {
                          setState(() => _pointsController.text = opt.toString());
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _enteredPoints == opt
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.h3,
                  decoration: InputDecoration(
                    labelText: 'Jumlah FinPoin yang Ditukar',
                    hintText: 'Minimal 100 FinPoin',
                    prefixIcon: const Icon(
                      Icons.redeem_rounded,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saldo FinPay Cash Diterima:',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        CurrencyFormatter.rupiah(_estimatedCash, withSign: true),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _submitRedeem,
                    icon: const Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isProcessing
                          ? 'Memproses Penukaran...'
                          : 'Cairkan ke Saldo FinPay Cash',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
