import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/icon_box.dart';

/// Halaman Penuh 6: Pembayaran & Tagihan PPOB (Desain Premium & Hidup).
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final List<Map<String, dynamic>> _billCategories = const [
    {'title': 'PLN Listrik', 'icon': Icons.bolt_rounded, 'color': AppColors.gold},
    {'title': 'Pulsa & Data', 'icon': Icons.phone_android_rounded, 'color': AppColors.primary},
    {'title': 'PDAM Air', 'icon': Icons.water_drop_rounded, 'color': AppColors.mint},
    {'title': 'BPJS Kesehatan', 'icon': Icons.health_and_safety_rounded, 'color': AppColors.danger},
    {'title': 'Internet & TV', 'icon': Icons.tv_rounded, 'color': Colors.purple},
    {'title': 'Voucher Game', 'icon': Icons.sports_esports_rounded, 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> _unpaidBills = [
    {
      'title': 'Token Listrik PLN',
      'id': '32189028 (An. Reza)',
      'dueDate': 'Jatuh tempo: 25 Okt 2024',
      'amount': 101500,
      'icon': Icons.bolt_rounded,
    },
    {
      'title': 'BPJS Kesehatan Keluarga',
      'id': '000128910291 (4 Jiwa)',
      'dueDate': 'Jatuh tempo: 30 Okt 2024',
      'amount': 150000,
      'icon': Icons.health_and_safety_rounded,
    },
    {
      'title': 'Indihome Internet & Wifi',
      'id': '12890192019',
      'dueDate': 'Jatuh tempo: 05 Nov 2024',
      'amount': 385000,
      'icon': Icons.wifi_rounded,
    },
  ];

  void _payBill(Map<String, dynamic> bill) {
    final amount = bill['amount'] as int;
    if (amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= amount;

    final newTrx = TransactionModel(
      title: 'Pembayaran ${bill['title']}',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Tagihan FinPay',
      amount: -amount,
      icon: bill['icon'] as IconData,
      type: TransactionType.expense,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Tagihan',
      adminFee: 1500,
      dateGroup: 'Hari Ini',
      note: 'Pembayaran ID: ${bill['id']}',
    );

    DummyData.transactions.insert(0, newTrx);

    setState(() {
      _unpaidBills.remove(bill);
    });

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
            Text('Tagihan Lunas! ⚡', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.rupiah(-amount, withSign: true),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.danger, fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pembayaran ${bill['title']} berhasil diproses.\nSisa Saldo: ${CurrencyFormatter.rupiah(DummyData.cashBalance)}',
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
        title: Text('Pembayaran & Tagihan', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka riwayat tagihan...')),
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
            // Grid Kategori Tagihan
            Text('Kategori Tagihan & PPOB', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                ),
                itemCount: _billCategories.length,
                itemBuilder: (context, index) {
                  final cat = _billCategories[index];
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka menu ${cat['title']}...')),
                      );
                    },
                    borderRadius: AppRadius.mdAll,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconBox(
                          icon: cat['icon'] as IconData,
                          size: 48,
                          iconSize: 24,
                          backgroundColor: AppColors.primaryLight,
                          iconColor: cat['color'] as Color,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['title'] as String,
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Tagihan Saya
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tagihan Rutin Saya', style: AppTextStyles.h3),
                Text('${_unpaidBills.length} Belum Dibayar', style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_unpaidBills.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 52, color: AppColors.success),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Semua Tagihan Lunas! 🎉', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text('Tidak ada tagihan rutin yang menunggak.', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              )
            else
              for (final bill in _unpaidBills) ...[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      IconBox(
                        icon: bill['icon'] as IconData,
                        size: 48,
                        iconSize: 24,
                        backgroundColor: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bill['title'] as String, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(bill['id'] as String, style: AppTextStyles.caption),
                            const SizedBox(height: 2),
                            Text(bill['dueDate'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.rupiah(bill['amount'] as int), style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => _payBill(bill),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}
