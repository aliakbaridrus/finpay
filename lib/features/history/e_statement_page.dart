import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh: Unduh Laporan e-Statement FinPay.
class EStatementPage extends StatefulWidget {
  const EStatementPage({super.key});

  @override
  State<EStatementPage> createState() => _EStatementPageState();
}

class _EStatementPageState extends State<EStatementPage> {
  String _selectedPeriod = 'Oktober 2024';
  String _selectedFormat = 'PDF';

  final List<String> _periods = ['Oktober 2024', 'September 2024', 'Agustus 2024'];
  final List<String> _formats = ['PDF', 'Excel (XLS)', 'Kirim ke Email'];

  void _downloadStatement() {
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
              child: const Icon(Icons.file_download_done_rounded, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('e-Statement Siap! 📄', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Laporan e-Statement $_selectedPeriod ($_selectedFormat) berhasil dibuat & dikirim ke email reza.pratama@email.com.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Buka File e-Statement'),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Unduh e-Statement', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Bantuan e-Statement...')),
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
                        label: 'Laporan Resmi FinPay',
                        leadingIcon: Icons.verified_rounded,
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                      ),
                      Text('Tersertifikasi OJK', style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Laporan Transaksi FinPay', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    'Unduh rincian mutasi resmi bulanan untuk kebutuhan pembukuan atau perpajakan.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
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
                  Text('Pilih Periode Laporan', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  for (final period in _periods)
                    RadioListTile<String>(
                      value: period,
                      groupValue: _selectedPeriod,
                      title: Text(period, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPeriod = val);
                      },
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  Text('Pilih Format File', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  for (final fmt in _formats)
                    RadioListTile<String>(
                      value: fmt,
                      groupValue: _selectedFormat,
                      title: Text(fmt, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFormat = val);
                      },
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
                  Text('Ringkasan Periode $_selectedPeriod', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.md),

                  _SummaryItemRow(label: 'Total Pemasukan', value: CurrencyFormatter.rupiah(DummyData.monthlyIncome), color: AppColors.success),
                  _SummaryItemRow(label: 'Total Pengeluaran', value: CurrencyFormatter.rupiah(DummyData.monthlyExpense), color: AppColors.danger),
                  _SummaryItemRow(
                    label: 'Perubahan Saldo Bersih',
                    value: CurrencyFormatter.rupiah(DummyData.monthlyIncome - DummyData.monthlyExpense, withSign: true),
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
                onPressed: _downloadStatement,
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                label: Text(
                  'Unduh Laporan ($_selectedFormat)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
