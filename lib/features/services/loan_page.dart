import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/wealth_models.dart';
import '../../data/services/wealth_service.dart';
import '../../shared/dialogs/widgets/finpay_receipt_dialog.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/rounded_progress_bar.dart';

/// Halaman Penuh 4: Pinjaman Instan (FinPay Loan) terintegrasi [WealthService] & koleksi `loans` (Bagian Tugas Pidi).
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
    final totalWithInterest = _loanAmount * (1 + (0.009 * _selectedTenorMonths));
    return (totalWithInterest / _selectedTenorMonths).round();
  }

  Future<void> _submitLoan() async {
    final amount = _loanAmount.round();
    final timeFormatted = TimeOfDay.now().format(context);
    try {
      final res = await WealthService.instance.applyLoan(
        amount: amount,
        tenorMonths: _selectedTenorMonths,
        timeFormatted: timeFormatted,
      );
      if (!mounted) return;
      await showFinPayReceiptDialog(
        context,
        title: 'Pinjaman Instan Disetujui! 🏦',
        amountText: CurrencyFormatter.rupiah(amount, withSign: true),
        amountColor: AppColors.success,
        referenceNumber: res.transaction.referenceNumber,
        details: [
          {'label': 'No. Referensi', 'value': res.transaction.referenceNumber},
          {'label': 'Tenor Cicilan', 'value': '$_selectedTenorMonths Bulan'},
          {
            'label': 'Cicilan / Bulan',
            'value': CurrencyFormatter.rupiah(res.loan.monthlyInstallment),
          },
          {
            'label': 'Saldo Cash Sekarang',
            'value': CurrencyFormatter.rupiah(DummyData.cashBalance),
          },
        ],
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _payInstallment(LoanModel loan) async {
    final timeFormatted = TimeOfDay.now().format(context);
    try {
      final res = await WealthService.instance.payLoanInstallment(
        loanId: loan.id,
        timeFormatted: timeFormatted,
      );
      if (!mounted) return;
      await showFinPayReceiptDialog(
        context,
        title: 'Pembayaran Cicilan Berhasil! ✅',
        amountText: CurrencyFormatter.rupiah(
          -res.loan.monthlyInstallment,
          withSign: true,
        ),
        amountColor: AppColors.danger,
        referenceNumber: res.transaction.referenceNumber,
        details: [
          {'label': 'No. Referensi', 'value': res.transaction.referenceNumber},
          {'label': 'Kontrak Pinjaman', 'value': res.loan.referenceNumber},
          {
            'label': 'Progres Cicilan',
            'value':
                '${res.loan.paidMonths} dari ${res.loan.tenorMonths} Bulan (${res.loan.status})',
          },
          {
            'label': 'Sisa Saldo Cash',
            'value': CurrencyFormatter.rupiah(DummyData.cashBalance),
          },
        ],
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
    return ValueListenableBuilder<List<LoanModel>>(
      valueListenable: WealthService.instance.activeLoansNotifier,
      builder: (context, loans, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.navy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pinjaman Instan (FinPay Loan)',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.mint,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pinjaman resmi terdaftar & diawasi OJK.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: SingleChildScrollView(
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
                              Text(
                                'Bunga Rendah 0.9%/bln',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Limit Pinjaman Instan s.d',
                            style: AppTextStyles.caption
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.rupiah(25000000),
                            style: AppTextStyles.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Persetujuan otomatis 5 menit, langsung cair ke Saldo FinPay Cash tanpa agunan.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Daftar Pinjaman Aktif & Bayar Cicilan
                    if (loans.isNotEmpty) ...[
                      Text(
                        'Tagihan & Cicilan Pinjaman (${loans.length})',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final loan in loans) ...[
                        _ActiveLoanCard(
                          loan: loan,
                          onPayTap: () => _payInstallment(loan),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // Simulation Form Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Simulasi Pengajuan Pinjaman',
                                style: AppTextStyles.h3,
                              ),
                              const Icon(
                                Icons.calculate_outlined,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Amount Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah Pinjaman',
                                style: AppTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                CurrencyFormatter.rupiah(_loanAmount.round()),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _loanAmount,
                            min: 1000000,
                            max: 25000000,
                            divisions: 24,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _loanAmount = val),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp 1.000.000',
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 11),
                              ),
                              Text(
                                'Rp 25.000.000',
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Tenor Selection Chips
                          Text(
                            'Pilih Tenor Cicilan',
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              for (final months in _tenorOptions)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedTenorMonths = months,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedTenorMonths == months
                                            ? AppColors.primary
                                            : AppColors.surface,
                                        borderRadius: AppRadius.pillAll,
                                        border: Border.all(
                                          color: _selectedTenorMonths == months
                                              ? AppColors.primary
                                              : AppColors.border,
                                        ),
                                        boxShadow:
                                            _selectedTenorMonths == months
                                                ? AppShadows.glow(
                                                    AppColors.primary,
                                                  )
                                                : null,
                                      ),
                                      child: Text(
                                        '$months Bulan',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.label.copyWith(
                                          color: _selectedTenorMonths == months
                                              ? Colors.white
                                              : AppColors.textPrimary,
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
                                    Text(
                                      'ESTIMASI CICILAN / BLN',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.rupiah(
                                        _monthlyInstallment,
                                      ),
                                      style: AppTextStyles.h1.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 22,
                                      ),
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
                        icon: const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Ajukan Pinjaman Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
            ),
          ),
        );
      },
    );
  }
}

class _ActiveLoanCard extends StatelessWidget {
  const _ActiveLoanCard({required this.loan, required this.onPayTap});

  final LoanModel loan;
  final VoidCallback onPayTap;

  @override
  Widget build(BuildContext context) {
    final progress = loan.tenorMonths > 0
        ? (loan.paidMonths / loan.tenorMonths).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pinjaman ${CurrencyFormatter.rupiah(loan.principalAmount)}',
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    'Ref: ${loan.referenceNumber}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              PillBadge(
                label: loan.isCompleted
                    ? 'Lunas'
                    : '${loan.paidMonths}/${loan.tenorMonths} Bln',
                backgroundColor: loan.isCompleted
                    ? AppColors.successLight
                    : AppColors.primaryLight,
                foregroundColor:
                    loan.isCompleted ? AppColors.success : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RoundedProgressBar(
            value: progress,
            color: loan.isCompleted ? AppColors.success : AppColors.primary,
            height: 8,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cicilan: ${CurrencyFormatter.rupiah(loan.monthlyInstallment)}/bln',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
              Text(
                'Sisa: ${CurrencyFormatter.rupiah(loan.remainingBalance)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          if (!loan.isCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPayTap,
                icon: const Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Bayar Cicilan Bulan Ini (${CurrencyFormatter.rupiah(loan.monthlyInstallment)})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
