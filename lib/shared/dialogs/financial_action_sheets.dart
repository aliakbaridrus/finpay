import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/pill_badge.dart';

/// Helper terpusat untuk memproses semua transaksi & aksi Keuangan
/// dengan Bottom Sheet berukuran 85% Viewport yang memiliki ruang luas tersendiri.
abstract class FinancialActionSheets {
  static void openAction(BuildContext context, String actionLabel, {VoidCallback? onStateChanged}) {
    final lower = actionLabel.toLowerCase();
    if (lower.contains('isi saldo') || lower.contains('top up')) {
      showTopUp(context, onStateChanged: onStateChanged);
    } else if (lower.contains('kirim') || lower.contains('transfer')) {
      showTransfer(context, onStateChanged: onStateChanged);
    } else if (lower.contains('menabung') || lower.contains('tabungan') || lower.contains('setor')) {
      showSaving(context, onStateChanged: onStateChanged);
    } else if (lower.contains('pinjam') || lower.contains('loan')) {
      showLoan(context, onStateChanged: onStateChanged);
    } else if (lower.contains('tagihan')) {
      showBillPayment(context, onStateChanged: onStateChanged);
    } else if (lower.contains('investasi')) {
      showInvestment(context, onStateChanged: onStateChanged);
    } else if (lower.contains('tarik')) {
      showCashout(context, onStateChanged: onStateChanged);
    } else if (lower.contains('qris')) {
      showQrisPay(context, onStateChanged: onStateChanged);
    } else if (lower.contains('cash flow')) {
      showCashFlowDetail(context);
    } else if (lower.contains('promo')) {
      showPromoList(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Membuka layanan $actionLabel...')),
      );
    }
  }

  static void showTopUp(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopUpSheet(onSuccess: onStateChanged),
    );
  }

  static void showTransfer(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferSheet(onSuccess: onStateChanged),
    );
  }

  static void showSaving(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SavingSheet(onSuccess: onStateChanged),
    );
  }

  static void showLoan(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LoanSheet(onSuccess: onStateChanged),
    );
  }

  static void showBillPayment(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BillPaymentSheet(onSuccess: onStateChanged),
    );
  }

  static void showInvestment(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestmentSheet(onSuccess: onStateChanged),
    );
  }

  static void showCashout(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CashoutSheet(onSuccess: onStateChanged),
    );
  }

  static void showQrisPay(BuildContext context, {VoidCallback? onStateChanged}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QrisPaySheet(onSuccess: onStateChanged),
    );
  }

  static void showCashFlowDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.donut_large_rounded, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Laporan Arus Kas FinPay', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Periode Bulan Oktober 2024', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.lg),

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.lgAll,
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(label: 'Total Pemasukan', value: CurrencyFormatter.rupiah(DummyData.monthlyIncome), color: AppColors.success),
                          const Divider(height: 20),
                          _SummaryRow(label: 'Total Pengeluaran', value: CurrencyFormatter.rupiah(DummyData.monthlyExpense), color: AppColors.danger),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Surplus Bersih',
                            value: CurrencyFormatter.rupiah(DummyData.monthlyIncome - DummyData.monthlyExpense, withSign: true),
                            color: AppColors.primary,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Tutup Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showPromoList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Promo & Cashback FinPay 🎉', style: AppTextStyles.h2),
                        const PillBadge(
                          label: '2 Voucher Aktif',
                          backgroundColor: AppColors.goldLight,
                          foregroundColor: Color(0xFFB45309),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _PromoCardTile(
                      title: 'Cashback 50% QRIS Indomaret',
                      subtitle: 'Maks. Rp 10.000 • Berlaku s.d 31 Okt',
                      code: 'FINQRIS50',
                      icon: Icons.qr_code_2_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _PromoCardTile(
                      title: 'Diskon Tagihan PLN Rp 15.000',
                      subtitle: 'Min. transaksi Rp 100.000 • s.d 15 Nov',
                      code: 'HEMATPLN',
                      icon: Icons.bolt_rounded,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 1. TOP UP / ISI SALDO SHEET (85% HEIGHT) ====================
class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  int _selectedAmount = 100000;
  String _selectedMethod = 'BCA Virtual Account';

  final List<int> _amounts = [50000, 100000, 200000, 500000, 1000000];
  final List<Map<String, String>> _methods = [
    {'name': 'BCA Virtual Account', 'desc': 'Bebas Biaya Admin • Instan', 'code': '88012'},
    {'name': 'Mandiri Virtual Account', 'desc': 'Bebas Biaya Admin • Instan', 'code': '88013'},
    {'name': 'QRIS Top Up', 'desc': 'Scan QRIS dari Mobile Banking', 'code': 'QRIS'},
    {'name': 'Indomaret / Alfamart', 'desc': 'Biaya Admin Rp 1.500', 'code': 'RETAIL'},
  ];

  void _processTopUp() {
    DummyData.cashBalance += _selectedAmount;

    final newTrx = TransactionModel(
      title: 'Isi Saldo $_selectedMethod',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: _selectedMethod,
      amount: _selectedAmount,
      icon: Icons.add_circle_outline_rounded,
      type: TransactionType.income,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Isi Saldo',
      dateGroup: 'Hari Ini',
      note: 'Top Up sukses via $_selectedMethod',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Isi Saldo Berhasil! 🎉',
      amountText: CurrencyFormatter.rupiah(_selectedAmount, withSign: true),
      amountColor: AppColors.success,
      details: [
        {'label': 'Metode Pembayaran', 'value': _selectedMethod},
        {'label': 'Tanggal & Waktu', 'value': 'Hari Ini, ${TimeOfDay.now().format(context)}'},
        {'label': 'Biaya Admin', 'value': 'Gratis'},
        {'label': 'Saldo FinPay Cash Baru', 'value': CurrencyFormatter.rupiah(DummyData.cashBalance)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Isi Saldo FinPay Cash', style: AppTextStyles.h2),
                  Text('Pilih nominal dan metode pembayaran resmi', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  // Context Balance Banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: AppColors.balanceGradient,
                      borderRadius: AppRadius.lgAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SALDO CASH SAAT INI', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text(CurrencyFormatter.rupiah(DummyData.cashBalance), style: AppTextStyles.h2.copyWith(color: Colors.white)),
                          ],
                        ),
                        const PillBadge(
                          label: '+ Top Up',
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text('Pilih Nominal Top Up', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final amt in _amounts)
                        GestureDetector(
                          onTap: () => setState(() => _selectedAmount = amt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedAmount == amt ? AppColors.primary : AppColors.surface,
                              borderRadius: AppRadius.pillAll,
                              border: Border.all(color: _selectedAmount == amt ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(
                              CurrencyFormatter.rupiah(amt),
                              style: AppTextStyles.label.copyWith(
                                color: _selectedAmount == amt ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text('Metode Pembayaran', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  for (final m in _methods)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedMethod == m['name'] ? AppColors.primary : AppColors.border,
                          width: _selectedMethod == m['name'] ? 1.5 : 1.0,
                        ),
                        borderRadius: AppRadius.mdAll,
                        color: _selectedMethod == m['name'] ? AppColors.primarySoft : AppColors.surface,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(m['name']!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['desc']!, style: AppTextStyles.caption),
                        leading: Icon(
                          _selectedMethod == m['name'] ? Icons.check_circle_rounded : Icons.account_balance_wallet_outlined,
                          color: _selectedMethod == m['name'] ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onTap: () => setState(() => _selectedMethod = m['name']!),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processTopUp,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      label: Text(
                        'Top Up ${CurrencyFormatter.rupiah(_selectedAmount)} Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 2. KIRIM UANG / TRANSFER SHEET (85% HEIGHT) ====================
class _TransferSheet extends StatefulWidget {
  const _TransferSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final TextEditingController _recipientController = TextEditingController(text: '0812-9988-7766 (Budi Santoso)');
  final TextEditingController _amountController = TextEditingController(text: '150000');
  final TextEditingController _noteController = TextEditingController(text: 'Patungan makan malam');

  void _processTransfer() {
    final amount = int.tryParse(_amountController.text) ?? 150000;
    if (amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= amount;

    final newTrx = TransactionModel(
      title: 'Transfer ke ${_recipientController.text}',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Antar FinPay',
      amount: -amount,
      icon: Icons.person_outline_rounded,
      type: TransactionType.expense,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Transfer',
      dateGroup: 'Hari Ini',
      note: _noteController.text,
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Transfer Berhasil! 💸',
      amountText: CurrencyFormatter.rupiah(-amount, withSign: true),
      amountColor: AppColors.danger,
      details: [
        {'label': 'Penerima', 'value': _recipientController.text},
        {'label': 'Kanal', 'value': 'Sesama FinPay (Bebas Biaya)'},
        {'label': 'Catatan', 'value': _noteController.text},
        {'label': 'Sisa Saldo Cash', 'value': CurrencyFormatter.rupiah(DummyData.cashBalance)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kirim Uang / Transfer', style: AppTextStyles.h2),
                  Text('Gratis biaya transfer sesama FinPay & Bank', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  TextField(
                    controller: _recipientController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Penerima (No. HP / Rekening Bank)',
                      prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.h3,
                    decoration: InputDecoration(
                      labelText: 'Nominal Transfer (Rp)',
                      prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: _noteController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Catatan Transfer (Opsional)',
                      prefixIcon: const Icon(Icons.note_alt_rounded, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadius.mdAll),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sumber Dana: FinPay Cash', style: AppTextStyles.caption),
                        Text(CurrencyFormatter.rupiah(DummyData.cashBalance), style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processTransfer,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      label: const Text('Konfirmasi Transfer Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. SETOR TABUNGAN SHEET (85% HEIGHT) ====================
class _SavingSheet extends StatefulWidget {
  const _SavingSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_SavingSheet> createState() => _SavingSheetState();
}

class _SavingSheetState extends State<_SavingSheet> {
  int _selectedAmount = 250000;

  void _processSaving() {
    if (_selectedAmount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= _selectedAmount;
    DummyData.savingBalance += _selectedAmount;

    final newTrx = TransactionModel(
      title: 'Pindah ke Target Tabungan Impian',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Auto-debet',
      amount: -_selectedAmount,
      icon: Icons.savings_outlined,
      type: TransactionType.saving,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Tabungan',
      dateGroup: 'Hari Ini',
      note: 'Setor tabungan impian',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Setoran Tabungan Berhasil! 🐷',
      amountText: CurrencyFormatter.rupiah(-_selectedAmount, withSign: true),
      amountColor: AppColors.primary,
      details: [
        {'label': 'Target Impian', 'value': 'Liburan ke Jepang ✈️'},
        {'label': 'Total Tabungan Terkumpul', 'value': CurrencyFormatter.rupiah(DummyData.savingBalance)},
        {'label': 'Bunga Tabungan', 'value': '3.5% / tahun'},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menabung & Setor Impian', style: AppTextStyles.h2),
                  Text('Kelola dan alokasikan tabungan impianmu', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.lgAll),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_outlined, size: 36, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target: Liburan ke Jepang ✈️', style: AppTextStyles.h3),
                              const SizedBox(height: 2),
                              Text('Terkumpul: ${CurrencyFormatter.rupiah(DummyData.savingBalance)} / Rp 15.000.000', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text('Pilih Nominal Setoran', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [100000, 250000, 500000, 1000000].map((amt) {
                      return ChoiceChip(
                        label: Text(CurrencyFormatter.rupiah(amt)),
                        selected: _selectedAmount == amt,
                        onSelected: (sel) {
                          if (sel) setState(() => _selectedAmount = amt);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _selectedAmount == amt ? Colors.white : AppColors.textPrimary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processSaving,
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: Text('Setor ${CurrencyFormatter.rupiah(_selectedAmount)} Sekarang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. PINJAMAN INSTAN SHEET (85% HEIGHT) ====================
class _LoanSheet extends StatefulWidget {
  const _LoanSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_LoanSheet> createState() => _LoanSheetState();
}

class _LoanSheetState extends State<_LoanSheet> {
  double _loanAmount = 5000000;

  void _processLoan() {
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
      note: 'Pencairan pinjaman instan ke saldo cash',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Pinjaman Cair! 🏦',
      amountText: CurrencyFormatter.rupiah(amount, withSign: true),
      amountColor: AppColors.success,
      details: [
        {'label': 'Penyedia Dana', 'value': 'FinPay Loan (Berizin OJK)'},
        {'label': 'Suku Bunga', 'value': '0.9% / bulan'},
        {'label': 'Tenor Cicilan', 'value': '6 Bulan'},
        {'label': 'Cicilan Bulanan', 'value': CurrencyFormatter.rupiah((amount / 6 * 1.05).round())},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pinjaman Instan FinPay', style: AppTextStyles.h2),
                      const PillBadge(label: 'OJK Verified', backgroundColor: AppColors.dangerLight, foregroundColor: AppColors.danger),
                    ],
                  ),
                  Text('Persetujuan 5 menit cair ke Saldo Cash', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xl),

                  Text('Jumlah Pengajuan: ${CurrencyFormatter.rupiah(_loanAmount.round())}', style: AppTextStyles.h3),
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
                      Text('Rp 1.000.000', style: AppTextStyles.caption),
                      Text('Rp 25.000.000', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processLoan,
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                      label: const Text('Ajukan Pinjaman Instan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 5. BAYAR TAGIHAN SHEET (85% HEIGHT) ====================
class _BillPaymentSheet extends StatefulWidget {
  const _BillPaymentSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_BillPaymentSheet> createState() => _BillPaymentSheetState();
}

class _BillPaymentSheetState extends State<_BillPaymentSheet> {
  final int _billAmount = 101500;

  void _processBill() {
    if (_billAmount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= _billAmount;

    final newTrx = TransactionModel(
      title: 'Pembelian Token PLN Electricity',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Tagihan FinPay',
      amount: -_billAmount,
      icon: Icons.bolt_rounded,
      type: TransactionType.expense,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Tagihan',
      adminFee: 1500,
      dateGroup: 'Hari Ini',
      note: 'Token PLN No. Meter 32189028',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Pembayaran PLN Berhasil! ⚡',
      amountText: CurrencyFormatter.rupiah(-_billAmount, withSign: true),
      amountColor: AppColors.danger,
      details: [
        {'label': 'Layanan', 'value': 'Token Listrik PLN'},
        {'label': 'No. Meter', 'value': '32189028 (An. Reza)'},
        {'label': 'Kode Token PLN', 'value': '8910-2391-4912-0019'},
        {'label': 'Sisa Saldo Cash', 'value': CurrencyFormatter.rupiah(DummyData.cashBalance)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bayar Tagihan & PPOB', style: AppTextStyles.h2),
                  Text('Pembayaran otomatis dengan struk lengkap', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  ListTile(
                    leading: const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 32),
                    title: const Text('Token PLN Listrik 100rb'),
                    subtitle: const Text('No. Meter: 32189028 • Biaya Admin Rp 1.500'),
                    trailing: Text(CurrencyFormatter.rupiah(_billAmount), style: AppTextStyles.h3),
                    tileColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processBill,
                      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                      label: const Text('Bayar Tagihan Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 6. INVESTASI SHEET (85% HEIGHT) ====================
class _InvestmentSheet extends StatefulWidget {
  const _InvestmentSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_InvestmentSheet> createState() => _InvestmentSheetState();
}

class _InvestmentSheetState extends State<_InvestmentSheet> {
  int _amount = 500000;

  void _processInvestment() {
    if (_amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= _amount;
    DummyData.investmentBalance += _amount;

    final newTrx = TransactionModel(
      title: 'Top Up Reksa Dana Pasar Uang',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'FinPay Invest',
      amount: -_amount,
      icon: Icons.trending_up_rounded,
      type: TransactionType.saving,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Investasi',
      dateGroup: 'Hari Ini',
      note: 'Pembelian unit Reksa Dana Pasar Uang',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Top Up Investasi Berhasil! 📈',
      amountText: CurrencyFormatter.rupiah(-_amount, withSign: true),
      amountColor: AppColors.primary,
      details: [
        {'label': 'Produk', 'value': 'Reksa Dana Pasar Uang'},
        {'label': 'Estimasi Imbal Hasil', 'value': '+4.5% / tahun'},
        {'label': 'Total Portofolio Investasi', 'value': CurrencyFormatter.rupiah(DummyData.investmentBalance)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Up Investasi FinPay', style: AppTextStyles.h2),
                  Text('Reksa Dana Pasar Uang • Imbal Hasil +4.5%/thn', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [100000, 250000, 500000, 1000000].map((amt) {
                      return ChoiceChip(
                        label: Text(CurrencyFormatter.rupiah(amt)),
                        selected: _amount == amt,
                        onSelected: (sel) {
                          if (sel) setState(() => _amount = amt);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _amount == amt ? Colors.white : AppColors.textPrimary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processInvestment,
                      icon: const Icon(Icons.trending_up_rounded, color: Colors.white),
                      label: Text('Beli Investasi ${CurrencyFormatter.rupiah(_amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 7. TARIK TUNAI SHEET (85% HEIGHT) ====================
class _CashoutSheet extends StatefulWidget {
  const _CashoutSheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_CashoutSheet> createState() => _CashoutSheetState();
}

class _CashoutSheetState extends State<_CashoutSheet> {
  int _amount = 200000;

  void _processCashout() {
    if (_amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= _amount;

    final newTrx = TransactionModel(
      title: 'Tarik Tunai Indomaret',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'Tarik Tunai',
      amount: -_amount,
      icon: Icons.payments_outlined,
      type: TransactionType.expense,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Tarik Tunai',
      dateGroup: 'Hari Ini',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Kode Tarik Tunai Dibuat! 🏪',
      amountText: CurrencyFormatter.rupiah(-_amount, withSign: true),
      amountColor: AppColors.danger,
      details: [
        {'label': 'Lokasi Penarikan', 'value': 'Kasir Indomaret / ATM'},
        {'label': 'Kode Token Penarikan', 'value': '8812-9921-4819'},
        {'label': 'Masa Berlaku Kode', 'value': '30 Menit'},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarik Tunai Tanpa Kartu', style: AppTextStyles.h2),
                  Text('Tarik saldo cash di Indomaret atau ATM terdekat', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.lg),

                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [100000, 200000, 500000, 1000000].map((amt) {
                      return ChoiceChip(
                        label: Text(CurrencyFormatter.rupiah(amt)),
                        selected: _amount == amt,
                        onSelected: (sel) {
                          if (sel) setState(() => _amount = amt);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _amount == amt ? Colors.white : AppColors.textPrimary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processCashout,
                      icon: const Icon(Icons.payments_outlined, color: Colors.white),
                      label: Text('Buat Kode Tarik ${CurrencyFormatter.rupiah(_amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 8. QRIS PAY SHEET (85% HEIGHT) ====================
class _QrisPaySheet extends StatefulWidget {
  const _QrisPaySheet({this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  State<_QrisPaySheet> createState() => _QrisPaySheetState();
}

class _QrisPaySheetState extends State<_QrisPaySheet> {
  final int _amount = 45000;

  void _processQris() {
    if (_amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo kamu tidak mencukupi!')),
      );
      return;
    }

    DummyData.cashBalance -= _amount;

    final newTrx = TransactionModel(
      title: 'Pembayaran QRIS Merchant Coffee',
      dateTime: 'Hari Ini, ${TimeOfDay.now().format(context)}',
      channel: 'QRIS Pay',
      amount: -_amount,
      icon: Icons.qr_code_scanner_rounded,
      type: TransactionType.expense,
      referenceNumber: 'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      category: 'Pembayaran QRIS',
      dateGroup: 'Hari Ini',
    );

    DummyData.transactions.insert(0, newTrx);
    widget.onSuccess?.call();

    Navigator.pop(context);
    _showReceiptDialog(
      context,
      title: 'Pembayaran QRIS Sukses! 📱',
      amountText: CurrencyFormatter.rupiah(-_amount, withSign: true),
      amountColor: AppColors.danger,
      details: [
        {'label': 'Merchant Name', 'value': 'Kopi Kenangan (Sudirman)'},
        {'label': 'Metode Pembayaran', 'value': 'QRIS FinPay Cash'},
        {'label': 'Sisa Saldo Cash', 'value': CurrencyFormatter.rupiah(DummyData.cashBalance)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.pillAll)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text('Simulasi Pembayaran QRIS', style: AppTextStyles.h2),
                  Text('Merchant: Kopi Kenangan • Rp 45.000', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processQris,
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text('Bayar Sekarang Rp 45.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER COMPONENTS ====================
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, required this.color, this.isBold = false});
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? AppTextStyles.body.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.caption),
        Text(value, style: isBold ? AppTextStyles.h3.copyWith(color: color) : AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PromoCardTile extends StatelessWidget {
  const _PromoCardTile({required this.title, required this.subtitle, required this.code, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final String code;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kode promo "$code" berhasil disalin!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Pakai', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ==================== UNIVERSAL STRUK RECEIPT DIALOG ====================
void _showReceiptDialog(
  BuildContext context, {
  required String title,
  required String amountText,
  required Color amountColor,
  required List<Map<String, String>> details,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      backgroundColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(amountText, style: AppTextStyles.displayLarge.copyWith(color: amountColor, fontSize: 28)),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),

          for (final item in details)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label']!, style: AppTextStyles.caption),
                  Flexible(
                    child: Text(
                      item['value']!,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menyiapkan file resi transaksi...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Bagikan Resi'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
        ],
      ),
    ),
  );
}
