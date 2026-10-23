import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../history/widgets/transaction_list_group.dart';

/// Halaman Penuh 5: Analisis Arus Kas / Cash Flow (Desain Premium & Hidup).
class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  String _selectedPeriod = 'Oktober 2024';

  final List<String> _periods = const ['Oktober 2024', 'September 2024', 'Agustus 2024'];

  int get _surplus => DummyData.monthlyIncome - DummyData.monthlyExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analisis Arus Kas', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengunduh Laporan Cash Flow PDF...')),
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
            // Period Dropdown Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Periode Laporan', style: AppTextStyles.h3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.card,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      items: _periods
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPeriod = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Dua Kartu Ringkasan (Pemasukan & Pengeluaran)
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: AppColors.successLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text('Pemasukan', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            CurrencyFormatter.rupiah(DummyData.monthlyIncome),
                            style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(DummyData.incomeGrowth, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: AppColors.primaryLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Pengeluaran', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            CurrencyFormatter.rupiah(DummyData.monthlyExpense),
                            style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(DummyData.expenseNote, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Surplus Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SURPLUS KEUANGAN BERSIH', style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.rupiah(_surplus, withSign: true),
                        style: AppTextStyles.h1.copyWith(color: AppColors.success, fontSize: 24),
                      ),
                    ],
                  ),
                  const PillBadge(
                    label: 'Kondisi Sehat 👍',
                    backgroundColor: AppColors.successLight,
                    foregroundColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Visual Chart Section
            Text('Grafik Arus Kas Mingguan', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _BarChartColumn(label: 'M1', incomeHeight: 60, expenseHeight: 30),
                      _BarChartColumn(label: 'M2', incomeHeight: 80, expenseHeight: 40),
                      _BarChartColumn(label: 'M3', incomeHeight: 50, expenseHeight: 35),
                      _BarChartColumn(label: 'M4', incomeHeight: 90, expenseHeight: 45),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.success, borderRadius: AppRadius.smAll)),
                      const SizedBox(width: 4),
                      Text('Pemasukan', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.smAll)),
                      const SizedBox(width: 4),
                      Text('Pengeluaran', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Rincian Riwayat Transaksi Lengkap Terkelompok
            Text('Rincian Transaksi $_selectedPeriod', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            TransactionListGroup(transactions: DummyData.transactions),
          ],
        ),
      ),
    );
  }
}

class _BarChartColumn extends StatelessWidget {
  const _BarChartColumn({
    required this.label,
    required this.incomeHeight,
    required this.expenseHeight,
  });

  final String label;
  final double incomeHeight;
  final double expenseHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 14,
              height: incomeHeight,
              decoration: BoxDecoration(color: AppColors.success, borderRadius: AppRadius.smAll),
            ),
            const SizedBox(width: 4),
            Container(
              width: 14,
              height: expenseHeight,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.smAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
