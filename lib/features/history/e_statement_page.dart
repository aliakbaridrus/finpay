// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/pdf_statement_generator.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wealth_models.dart';
import '../../data/services/account_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/wealth_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh: Unduh Laporan e-Statement FinPay (.PDF) terintegrasi [WealthService] (Bagian Tugas Pidi).
class EStatementPage extends StatefulWidget {
  const EStatementPage({super.key});

  @override
  State<EStatementPage> createState() => _EStatementPageState();
}

class _EStatementPageState extends State<EStatementPage> {
  String _selectedPeriod = 'Semua Waktu';
  bool _isDownloading = false;

  List<String> get _periods => [
        ...WealthService.availablePeriods,
        if (!_isPreset(_selectedPeriod)) _selectedPeriod,
      ];

  bool _isPreset(String period) =>
      WealthService.availablePeriods.contains(period);

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

  Future<void> _downloadStatement() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final user = AccountService.instance.currentUser;
      final allTrx = TransactionService.instance.transactionsNotifier.value;
      final filteredTrx = WealthService.instance.filterTransactionsByPeriod(
        allTrx,
        _selectedPeriod,
      );
      final summary = WealthService.instance.calculateCashFlowSummary(
        period: _selectedPeriod,
        customTransactions: filteredTrx,
      );
      final generatedDate = AuthService.formatDeviceDate(DateTime.now());

      final pdfBytes = PdfStatementGenerator.generatePdfBytes(
        user: user,
        summary: summary,
        transactions: filteredTrx,
        periodLabel: _selectedPeriod,
        generatedDateLabel: generatedDate,
      );

      final safePeriodName = _selectedPeriod
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      final fileName = 'FinPay_eStatement_$safePeriodName.pdf';

      final savedPath = await PdfStatementGenerator.downloadPdfFile(
        fileName: fileName,
        bytes: pdfBytes,
      );

      if (!mounted) return;
      setState(() => _isDownloading = false);

      await _showPrintableStatementPreview(
        fileName: fileName,
        savedPath: savedPath,
        generatedDate: generatedDate,
        summary: summary,
        transactions: filteredTrx,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showPrintableStatementPreview({
    required String fileName,
    required String savedPath,
    required String generatedDate,
    required CashFlowSummaryModel summary,
    required List<TransactionModel> transactions,
  }) async {
    final user = AccountService.instance.currentUser;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxContentWidth,
            maxHeight: 620,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File .PDF Berhasil Diunduh!',
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            fileName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tersimpan di: $savedPath',
                  style: AppTextStyles.caption,
                ),
                const Divider(height: 24, color: AppColors.border),

                // Preview Lembar Statement Resmi dalam Rentang Waktu
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FINPAY E-STATEMENT (.PDF)',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pemilik: ${user.fullName} (${user.email})\n'
                            'Periode: $_selectedPeriod\n'
                            'Dicetak: $generatedDate',
                            style: AppTextStyles.caption.copyWith(height: 1.4),
                          ),
                          const Divider(height: 16),
                          _SummaryItemRow(
                            label: 'Total Pemasukan',
                            value: CurrencyFormatter.rupiah(summary.totalIncome),
                            color: AppColors.success,
                          ),
                          _SummaryItemRow(
                            label: 'Total Pengeluaran',
                            value:
                                CurrencyFormatter.rupiah(summary.totalExpense),
                            color: AppColors.danger,
                          ),
                          _SummaryItemRow(
                            label: 'Surplus Bersih',
                            value: CurrencyFormatter.rupiah(
                              summary.netSurplus,
                              withSign: true,
                            ),
                            color: AppColors.primary,
                            isBold: true,
                          ),
                          const Divider(height: 16),
                          Text(
                            'RINCIAN MUTASI (${transactions.length} Transaksi)',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (transactions.isEmpty)
                            Text(
                              'Belum ada transaksi pada rentang waktu ini.',
                              style: AppTextStyles.caption,
                            )
                          else
                            for (final trx in transactions)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${trx.dateTime} • ${trx.title}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      CurrencyFormatter.rupiah(
                                        trx.amount,
                                        withSign: true,
                                      ),
                                      style: AppTextStyles.caption.copyWith(
                                        color: trx.isIncoming
                                            ? AppColors.success
                                            : AppColors.danger,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Selesai & Tutup Preview PDF'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TransactionModel>>(
      valueListenable: TransactionService.instance.transactionsNotifier,
      builder: (context, allTrx, _) {
        final filteredTrx = WealthService.instance.filterTransactionsByPeriod(
          allTrx,
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
            title: Text('Unduh e-Statement (.PDF)', style: AppTextStyles.h2),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Pilih Rentang Tanggal Kustom',
                onPressed: _pickCustomDateRange,
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
                    // Top Context Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.balanceGradient,
                        borderRadius: AppRadius.xlAll,
                        boxShadow: AppShadows.glow(AppColors.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const PillBadge(
                                label: 'Dokumen Cetak Resmi (.PDF)',
                                leadingIcon: Icons.picture_as_pdf_rounded,
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                              ),
                              Text(
                                'Skor Kesehatan: ${summary.financialHealthScore}/100',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Laporan e-Statement FinPay',
                            style:
                                AppTextStyles.h2.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Unduh file cetak e-Statement (.pdf) ke perangkatmu berdasarkan rentang hari, bulan, atau tahun.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Form Selection Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pilih Rentang Waktu',
                                style: AppTextStyles.h3,
                              ),
                              TextButton.icon(
                                onPressed: _pickCustomDateRange,
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 16,
                                ),
                                label: const Text('Rentang Kustom'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          for (final period in _periods)
                            RadioListTile<String>(
                              value: period,
                              groupValue: _selectedPeriod,
                              title: Text(
                                period,
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedPeriod = val);
                                }
                              },
                            ),
                          const Divider(height: 24, color: AppColors.border),
                          Text(
                            'Format Output Dokumen',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dokumen Cetak PDF (.pdf)',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        'Standar dokumen e-Statement resmi (Hanya menerima format .pdf)',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Summary Info Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Ringkasan $_selectedPeriod (${filteredTrx.length} Trx)',
                                  style: AppTextStyles.h3,
                                ),
                              ),
                              PillBadge(
                                label: summary.healthStatusLabel,
                                backgroundColor: AppColors.successLight,
                                foregroundColor: AppColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: AppSpacing.md),
                          _SummaryItemRow(
                            label: 'Total Pemasukan',
                            value:
                                CurrencyFormatter.rupiah(summary.totalIncome),
                            color: AppColors.success,
                          ),
                          _SummaryItemRow(
                            label: 'Total Pengeluaran',
                            value:
                                CurrencyFormatter.rupiah(summary.totalExpense),
                            color: AppColors.danger,
                          ),
                          _SummaryItemRow(
                            label: 'Alokasi Tabungan Impian',
                            value:
                                CurrencyFormatter.rupiah(summary.totalSaving),
                            color: AppColors.primary,
                          ),
                          _SummaryItemRow(
                            label: 'Perubahan Saldo Bersih',
                            value: CurrencyFormatter.rupiah(
                              summary.netSurplus,
                              withSign: true,
                            ),
                            color: AppColors.primary,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _downloadStatement,
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isDownloading
                              ? 'Menyiapkan File .PDF...'
                              : 'Unduh & Cetak e-Statement (.PDF)',
                          style: const TextStyle(
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

class _SummaryItemRow extends StatelessWidget {
  const _SummaryItemRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTextStyles.body.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.caption),
          Text(value, style: AppTextStyles.label.copyWith(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
