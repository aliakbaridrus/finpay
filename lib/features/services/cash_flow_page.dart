import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/wealth_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../history/e_statement_page.dart';
import '../history/widgets/transaction_list_group.dart';

/// Halaman Penuh 5: Analisis Arus Kas / Cash Flow terintegrasi [WealthService] (Bagian Tugas Pidi).
class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  String _selectedPeriod = 'Semua Waktu';

  List<String> get _periods => [
        ...WealthService.availablePeriods,
        if (!_isPreset(_selectedPeriod)) _selectedPeriod,
        'Pilih Rentang Tanggal (Kustom)',
      ];

  bool _isPreset(String period) =>
      WealthService.availablePeriods.contains(period) ||
      period == 'Pilih Rentang Tanggal (Kustom)';

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    if (range != null && mounted) {
      final startStr = AuthService.formatDeviceDate(range.start);
      final endStr = AuthService.formatDeviceDate(range.end);
      setState(() {
        _selectedPeriod = '$startStr - $endStr';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TransactionModel>>(
      valueListenable: TransactionService.instance.transactionsNotifier,
      builder: (context, transactions, _) {
        final filteredTrx = WealthService.instance.filterTransactionsByPeriod(
          transactions,
          _selectedPeriod,
        );
        final summary = WealthService.instance.calculateCashFlowSummary(
          period: _selectedPeriod,
          customTransactions: filteredTrx,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Analisis Arus Kas', style: AppTextStyles.h2),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Unduh E-Statement',
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => const EStatementPage()),
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
                    // Period Dropdown Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Periode Laporan', style: AppTextStyles.h3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.pillAll,
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppShadows.card,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPeriod,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              items: _periods
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) async {
                                if (val != null) {
                                  if (val.contains('Kustom')) {
                                    await _pickCustomDateRange();
                                  } else {
                                    setState(() => _selectedPeriod = val);
                                  }
                                }
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
                                    const Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pemasukan',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    CurrencyFormatter.rupiah(
                                      summary.totalIncome,
                                    ),
                                    style: AppTextStyles.h1.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  summary.incomeGrowthLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                    const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pengeluaran',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    CurrencyFormatter.rupiah(
                                      summary.totalExpense,
                                    ),
                                    style: AppTextStyles.h1.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  summary.expenseRatioLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Surplus & Skor Kesehatan Finansial Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      color: AppColors.surface,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SURPLUS BERSIH • SKOR ${summary.financialHealthScore}/100',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.rupiah(
                                    summary.netSurplus,
                                    withSign: true,
                                  ),
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.success,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PillBadge(
                            label: summary.healthStatusLabel,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _BarChartColumn(
                                label: 'M1',
                                incomeHeight: summary.totalIncome > 0 ? 60 : 4,
                                expenseHeight: summary.totalExpense > 0 ? 30 : 4,
                              ),
                              _BarChartColumn(
                                label: 'M2',
                                incomeHeight: summary.totalIncome > 0 ? 80 : 4,
                                expenseHeight: summary.totalExpense > 0 ? 40 : 4,
                              ),
                              _BarChartColumn(
                                label: 'M3',
                                incomeHeight: summary.totalIncome > 0 ? 50 : 4,
                                expenseHeight: summary.totalExpense > 0 ? 35 : 4,
                              ),
                              _BarChartColumn(
                                label: 'M4',
                                incomeHeight: summary.totalIncome > 0 ? 90 : 4,
                                expenseHeight: summary.totalExpense > 0 ? 45 : 4,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: AppRadius.smAll,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pemasukan',
                                style: AppTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadius.smAll,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pengeluaran',
                                style: AppTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Rincian Riwayat Transaksi Lengkap Terkelompok
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rincian Transaksi $_selectedPeriod',
                          style: AppTextStyles.h3,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EStatementPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.file_download_outlined,
                            size: 16,
                          ),
                          label: const Text('E-Statement'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TransactionListGroup(transactions: filteredTrx),
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
