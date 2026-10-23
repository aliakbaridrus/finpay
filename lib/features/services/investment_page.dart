import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh 7: Portofolio Investasi (Desain Premium & Hidup).
class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  String _selectedRange = '3M';

  final List<String> _ranges = const ['1M', '3M', '1Y'];

  void _topUpInvestment(String product, int amount) {
    if (amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= amount;
    DummyData.investmentBalance += amount;

    final newTrx = TransactionModel(
      title: 'Top Up $product',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'FinPay Invest',
      amount: -amount,
      icon: Icons.trending_up_rounded,
      type: TransactionType.saving,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Investasi',
      dateGroup: 'Hari Ini',
      note: 'Pembelian unit $product',
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
              child: const Icon(Icons.trending_up_rounded, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Investasi Berhasil! 📈', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.rupiah(amount),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary, fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Berhasil menambahkan unit $product.\nTotal Portofolio Investasi: ${CurrencyFormatter.rupiah(DummyData.investmentBalance)}',
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

  void _sellInvestment(String product, int amount) {
    if (amount > DummyData.investmentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai investasi tidak cukup!')),
      );
      return;
    }

    DummyData.investmentBalance -= amount;
    DummyData.cashBalance += amount;

    final newTrx = TransactionModel(
      title: 'Pencairan $product',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'FinPay Invest',
      amount: amount,
      icon: Icons.account_balance_wallet_outlined,
      type: TransactionType.income,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Investasi',
      dateGroup: 'Hari Ini',
      note: 'Pencairan investasi ke saldo cash',
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
            Text('Pencairan Berhasil! 💰', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.rupiah(amount, withSign: true),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.success, fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dana investasi sebesar ${CurrencyFormatter.rupiah(amount)} berhasil dicairkan ke Saldo Cash.',
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Portofolio Investasi', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka analisis grafik investasi...')),
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
            // Kartu Total Portofolio
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                      Text('TOTAL NILAI PORTOFOLIO', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, letterSpacing: 1)),
                      const PillBadge(label: 'Risiko Rendah', backgroundColor: Colors.white24, foregroundColor: Colors.white),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CurrencyFormatter.rupiah(DummyData.investmentBalance),
                    style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: AppColors.mint, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${CurrencyFormatter.rupiah(DummyData.investmentReturn, withSign: true)} (+4.5%) Pertumbuhan',
                        style: AppTextStyles.label.copyWith(color: AppColors.mint, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Visual Chart Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tren Pergerakan Nilai', style: AppTextStyles.h3),
                Row(
                  children: [
                    for (final r in _ranges)
                      GestureDetector(
                        onTap: () => setState(() => _selectedRange = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedRange == r ? AppColors.primary : AppColors.surface,
                            borderRadius: AppRadius.pillAll,
                            border: Border.all(color: _selectedRange == r ? AppColors.primary : AppColors.border),
                            boxShadow: _selectedRange == r ? AppShadows.glow(AppColors.primary) : null,
                          ),
                          child: Text(
                            r,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _selectedRange == r ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _ChartPainter(),
                  child: const Center(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Produk Aktif
            Text('Produk Investasi Aktif', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),

            // Product 1
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reksa Dana Pasar Uang FinPay', style: AppTextStyles.h3),
                      const PillBadge(label: '+4.2%/thn', backgroundColor: AppColors.mintLight, foregroundColor: Color(0xFF0F766E)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Nilai Saat Ini: ${CurrencyFormatter.rupiah(7500000)}', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _sellInvestment('Reksa Dana Pasar Uang', 500000),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.dangerLight),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Cairkan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _topUpInvestment('Reksa Dana Pasar Uang', 500000),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Product 2
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reksa Dana Saham BlueChip', style: AppTextStyles.h3),
                      const PillBadge(label: '+5.1%/thn', backgroundColor: AppColors.mintLight, foregroundColor: Color(0xFF0F766E)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Nilai Saat Ini: ${CurrencyFormatter.rupiah(2500000)}', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _sellInvestment('Reksa Dana Saham BlueChip', 250000),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.dangerLight),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Cairkan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _topUpInvestment('Reksa Dana Saham BlueChip', 250000),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.3, size.width * 0.75, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
