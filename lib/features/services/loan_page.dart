import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh 4: Pinjaman Instan (FinPay Loan - Desain Premium & Hidup).
class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  double _loanAmount = 5000000;
  int _selectedTenorMonths = 6;

  final List<int> _tenorOptions = [3, 6, 12];

  int get _monthlyInstallment {
    final principal = _loanAmount / _selectedTenorMonths;
    final interest = principal * 0.009; // 0.9%/bln
    return (principal + interest).round();
  }

  void _submitLoan() {
    final amount = _loanAmount.round();
    DummyData.cashBalance += amount;

    final newTrx = TransactionModel(
      title: 'Pencairan Pinjaman FinPay Loan',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'FinPay Loan OJK',
      amount: amount,
      icon: Icons.account_balance_wallet_outlined,
      type: TransactionType.income,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Pinjaman',
      dateGroup: 'Hari Ini',
      note: 'Pencairan pinjaman instan $_selectedTenorMonths bulan',
    );

    DummyData.transactions.insert(0, newTrx);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 52, color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Pinjaman Instan Disetujui! 🏦', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.rupiah(amount, withSign: true),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.success, fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dana pinjaman sebesar ${CurrencyFormatter.rupiah(amount)} langsung dicairkan ke Saldo FinPay Cash kamu.\nCicilan: ${CurrencyFormatter.rupiah(_monthlyInstallment)}/bulan ($_selectedTenorMonths Bulan)',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pinjaman Instan (FinPay Loan)', style: AppTextStyles.h2.copyWith(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_rounded, color: AppColors.mint),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pinjaman resmi terdaftar & diawasi OJK.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Penawaran Utama Navy Gradient dengan Glow Shadow
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.loanGradient,
                borderRadius: AppRadius.xlAll,
                boxShadow: AppShadows.glow(AppColors.navy),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const PillBadge(
                        label: '● FinPay Loan • Izin OJK',
                        leadingIcon: Icons.verified_rounded,
                        backgroundColor: Colors.white24,
                        foregroundColor: AppColors.mint,
                      ),
                      Text('Bunga Rendah 0.9%/bln', style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Limit Pinjaman Instan s.d', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.rupiah(25000000),
                    style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Persetujuan otomatis 5 menit, langsung cair ke Saldo FinPay Cash tanpa agunan.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Simulation Form Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Simulasi Pengajuan Pinjaman', style: AppTextStyles.h3),
                      const Icon(Icons.calculate_outlined, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Amount Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumlah Pinjaman', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        CurrencyFormatter.rupiah(_loanAmount.round()),
                        style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 20),
                      ),
                    ],
                  ),
                  Slider(
                    value: _loanAmount,
                    min: 1000000,
                    max: 25000000,
                    divisions: 24,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _loanAmount = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp 1.000.000', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                      Text('Rp 25.000.000', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tenor Selection Chips
                  Text('Pilih Tenor Cicilan', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (final months in _tenorOptions)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTenorMonths = months),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTenorMonths == months ? AppColors.primary : AppColors.surface,
                                borderRadius: AppRadius.pillAll,
                                border: Border.all(
                                  color: _selectedTenorMonths == months ? AppColors.primary : AppColors.border,
                                ),
                                boxShadow: _selectedTenorMonths == months ? AppShadows.glow(AppColors.primary) : null,
                              ),
                              child: Text(
                                '$months Bulan',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.label.copyWith(
                                  color: _selectedTenorMonths == months ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.sm),

                  // Estimasi Rincian
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ESTIMASI CICILAN / BLN', style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.rupiah(_monthlyInstallment),
                              style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 22),
                            ),
                          ],
                        ),
                        const PillBadge(
                          label: 'Bunga 0.9%',
                          backgroundColor: AppColors.mintLight,
                          foregroundColor: Color(0xFF0F766E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitLoan,
                icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                label: const Text(
                  'Ajukan Pinjaman Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
