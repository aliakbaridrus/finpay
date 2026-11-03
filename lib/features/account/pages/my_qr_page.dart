import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/qris_model.dart';
import '../../../data/services/qris_service.dart';
import '../../../shared/widgets/qris_code_card.dart';
import '../widgets/sub_page_scaffold.dart';

/// QRIS Saya: kartu QRIS asli untuk menerima pembayaran dari aplikasi bank /
/// e-wallet lain. Mendukung QRIS statis (tanpa nominal) dan dinamis (nominal terkunci).
class MyQrPage extends StatefulWidget {
  const MyQrPage({super.key});

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isDynamic = false;
  int? _lockedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  QrisPayload get _payload =>
      QrisService.instance.myQris(amount: _isDynamic ? _lockedAmount : null);

  void _setMode(bool dynamicMode) {
    setState(() {
      _isDynamic = dynamicMode;
      if (!dynamicMode) {
        _lockedAmount = null;
        _amountController.clear();
      }
    });
  }

  void _applyAmount() {
    final amount = int.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll('Rp', '').trim(),
    );
    try {
      if (amount == null) {
        throw const QrisFormatException('Masukkan nominal yang valid.');
      }
      QrisService.instance.validateAmount(amount);
      FocusScope.of(context).unfocus();
      setState(() => _lockedAmount = amount);
    } on QrisFormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _copyQris() {
    Clipboard.setData(ClipboardData(text: _payload.encode()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode QRIS disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload;
    final needsAmount = _isDynamic && _lockedAmount == null;

    return SubPageScaffold(
      title: 'QRIS Saya',
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.balanceGradient,
            borderRadius: AppRadius.xlAll,
            boxShadow: AppShadows.glow(AppColors.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(
                  'Terima pembayaran ke',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DummyData.userName,
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (needsAmount)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.xlAll,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Atur nominal untuk membuat QRIS dinamis',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  )
                else
                  QrisCodeCard(
                    data: payload.encode(),
                    merchantName: payload.merchantName,
                    nmid: payload.nmid,
                    amount: payload.amount,
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  DummyData.phoneNumber,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ModeChip(
                label: 'QRIS Statis',
                icon: Icons.qr_code_2_rounded,
                selected: !_isDynamic,
                onTap: () => _setMode(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ModeChip(
                label: 'QRIS Dinamis',
                icon: Icons.lock_clock_rounded,
                selected: _isDynamic,
                onTap: () => _setMode(true),
              ),
            ),
          ],
        ),
        if (_isDynamic) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal tagihan (Rp)',
                    prefixIcon: const Icon(Icons.payments_rounded),
                    helperText: _lockedAmount == null
                        ? 'Min Rp 1.000 • Maks Rp 10.000.000'
                        : 'Terkunci: ${CurrencyFormatter.rupiah(_lockedAmount!)}',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                  ),
                  onSubmitted: (_) => _applyAmount(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: _applyAmount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(88, 56),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ),
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: needsAmount ? null : _copyQris,
                icon: const Icon(Icons.copy_rounded, size: AppSizes.iconMd),
                label: Text(
                  'Salin Kode QRIS',
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: needsAmount
                    ? null
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bagikan belum tersedia (demo)'),
                          ),
                        ),
                icon: const Icon(Icons.ios_share_rounded, size: AppSizes.iconMd),
                label: Text(
                  'Bagikan',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconMd,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
