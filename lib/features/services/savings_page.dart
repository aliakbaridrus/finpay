import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/rounded_progress_bar.dart';

/// Halaman Penuh 3: Target Menabung.
class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  void _setorTabungan(String title, int amount) {
    if (amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= amount;
    DummyData.savingBalance += amount;

    final newTrx = TransactionModel(
      title: 'Pindah ke $title',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Auto-debet Tabungan',
      amount: -amount,
      icon: Icons.savings_outlined,
      type: TransactionType.saving,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Tabungan',
      dateGroup: 'Hari Ini',
      note: 'Setoran tabungan $title',
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
              child: const Icon(Icons.savings_outlined, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Setoran Tabungan Berhasil! 🐷', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.rupiah(amount),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary, fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Berhasil disetorkan ke $title.\nTotal Tabungan Terkumpul: ${CurrencyFormatter.rupiah(DummyData.savingBalance)}',
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
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buatTargetBaruModal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Buat Target Menabung Baru', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Target (Mis. Beli Laptop Baru)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Target "${titleController.text}" berhasil dibuat! 🎉')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Simpan Target Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
        title: Text('Target Menabung', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka riwayat tabungan...')),
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
            // Banner Ringkasan Total Tabungan Terkumpul
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
                      Text('TOTAL TABUNGAN TERKUMPUL', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, letterSpacing: 1)),
                      const PillBadge(label: 'Bunga 3.5%/thn', backgroundColor: Colors.white24, foregroundColor: Colors.white),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CurrencyFormatter.rupiah(DummyData.savingBalance),
                    style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Aset tabungan kamu dijamin aman oleh LPS', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Heading & Create Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daftar Impian Kamu', style: AppTextStyles.h3),
                ElevatedButton.icon(
                  onPressed: _buatTargetBaruModal,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('+ Target Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Goal Card 1: Liburan ke Jepang
            _GoalCardFull(
              title: 'Liburan ke Jepang ✈️',
              currentAmount: 7500000,
              targetAmount: 15000000,
              monthlyDebit: 500000,
              eta: 'Mei 2025',
              color: AppColors.primary,
              onSetorTap: () => _setorTabungan('Liburan ke Jepang ✈️', 500000),
            ),
            const SizedBox(height: AppSpacing.md),

            // Goal Card 2: Dana Darurat
            _GoalCardFull(
              title: 'Dana Darurat 6 Bulan 🛡️',
              currentAmount: 8000000,
              targetAmount: 10000000,
              monthlyDebit: 1000000,
              eta: 'Desember 2024',
              color: AppColors.mint,
              onSetorTap: () => _setorTabungan('Dana Darurat 6 Bulan 🛡️', 500000),
            ),
            const SizedBox(height: AppSpacing.md),

            // Goal Card 3: Laptop Baru
            _GoalCardFull(
              title: 'Beli Laptop Workstation 💻',
              currentAmount: 3000000,
              targetAmount: 12000000,
              monthlyDebit: 750000,
              eta: 'Agustus 2025',
              color: AppColors.gold,
              onSetorTap: () => _setorTabungan('Beli Laptop Workstation 💻', 250000),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCardFull extends StatelessWidget {
  const _GoalCardFull({
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthlyDebit,
    required this.eta,
    required this.color,
    required this.onSetorTap,
  });

  final String title;
  final int currentAmount;
  final int targetAmount;
  final int monthlyDebit;
  final String eta;
  final Color color;
  final VoidCallback onSetorTap;

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get percentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h3)),
              PillBadge(
                label: '$percentage%',
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Auto-debet: ${CurrencyFormatter.rupiah(monthlyDebit)}/bulan', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),

          RoundedProgressBar(value: progress, color: color, height: 8),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(CurrencyFormatter.rupiah(currentAmount), style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Text('Target: ${CurrencyFormatter.rupiah(targetAmount)}', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimasi Tercapai: $eta', style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ElevatedButton.icon(
                onPressed: onSetorTap,
                icon: const Icon(Icons.add, size: 14, color: Colors.white),
                label: const Text('+ Setor Dana', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
