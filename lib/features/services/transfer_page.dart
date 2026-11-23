import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/wallet_model.dart';
import '../../data/services/wallet_service.dart';
import '../../shared/dialogs/widgets/finpay_receipt_dialog.dart';
import '../../shared/dialogs/widgets/midtrans_snap_simulator_dialog.dart';
import '../../shared/widgets/app_card.dart';

/// Halaman Penuh 2: Kirim Uang / Transfer terintegrasi WalletService (Bagian Ali).
class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _recipientController =
      TextEditingController(text: '0812-9988-7766 (Budi Santoso)');
  final TextEditingController _amountController =
      TextEditingController(text: '250000');
  final TextEditingController _noteController =
      TextEditingController(text: 'Uang patungan');

  final List<Map<String, String>> _recentContacts = [
    {
      'name': 'Ali Akbar',
      'phone': '087841819117',
      'initials': 'AA',
      'bank': 'FinPay'
    },
    {
      'name': 'Reza Pratama',
      'phone': '0812-3456-7890',
      'initials': 'RP',
      'bank': 'FinPay'
    },
    {
      'name': 'Budi Santoso',
      'phone': '0812-9988-7766',
      'initials': 'BS',
      'bank': 'FinPay'
    },
    {
      'name': 'Siska Pertiwi',
      'phone': '0813-1122-3344',
      'initials': 'SP',
      'bank': 'BCA'
    },
    {
      'name': 'Eko Kurniawan',
      'phone': '0857-4455-6677',
      'initials': 'EK',
      'bank': 'Mandiri'
    },
  ];

  String _contactQuery = '';

  List<Map<String, String>> get _filteredContacts {
    final q = _contactQuery.trim().toLowerCase();
    if (q.isEmpty) return _recentContacts;
    return _recentContacts.where((c) {
      return c['name']!.toLowerCase().contains(q) ||
          c['phone']!.toLowerCase().contains(q) ||
          c['bank']!.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _processTransfer() async {
    final amount = int.tryParse(
          _amountController.text
              .replaceAll('.', '')
              .replaceAll('Rp', '')
              .trim(),
        ) ??
        0;
    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor HP atau penerima tujuan.')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transfer harus lebih dari Rp 0.')),
      );
      return;
    }
    if (amount > DummyData.cashBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo FinPay Cash kamu tidak mencukupi!')),
      );
      return;
    }

    final isBankTransfer = _tabController.index == 1;
    MidtransSnapBridgeResult? bridgeResult;

    // Popup jembatan Midtrans Snap hanya untuk tab 'Ke Rekening Bank'.
    // Untuk 'Ke Sesama FinPay', transfer langsung memotong FinPay Cash & masuk ke penerima.
    if (isBankTransfer) {
      bridgeResult = await showMidtransSnapSimulator(
        context,
        merchantTitle: 'FinPay Transfer Bank',
        amount: amount,
        recipientLabel: recipient,
      );
      if (bridgeResult == null || !mounted) return;
    }

    final timeFormatted = TimeOfDay.now().format(context);

    try {
      final trx = await WalletService.instance.transferMoney(
        recipient: recipient,
        amount: amount,
        isBankTransfer: isBankTransfer,
        timeFormatted: timeFormatted,
        note: _noteController.text,
        midtransOrderId: bridgeResult?.order.orderId,
        midtransMethod: bridgeResult?.paymentMethod,
      );

      if (!mounted) return;

      await showFinPayReceiptDialog(
        context,
        title: isBankTransfer
            ? 'Transfer Bank via Midtrans Berhasil! 💸'
            : 'Transfer Sesama FinPay Berhasil! 💸',
        amountText: CurrencyFormatter.rupiah(-amount, withSign: true),
        amountColor: AppColors.danger,
        referenceNumber: trx.referenceNumber,
        details: [
          if (bridgeResult != null) ...[
            {'label': 'Order ID Midtrans', 'value': bridgeResult.order.orderId},
            {'label': 'Metode Jembatan', 'value': bridgeResult.paymentMethod},
          ] else
            {'label': 'Metode', 'value': 'FinPay Cash (Instan)'},
          {'label': 'Penerima', 'value': recipient},
          {'label': 'Status', 'value': 'BERHASIL'},
          {
            'label': 'Sisa Saldo Cash',
            'value': CurrencyFormatter.rupiah(DummyData.cashBalance),
          },
        ],
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Transfer & Kirim Uang', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Bantuan Transfer...')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.label,
          tabs: const [
            Tab(text: 'Ke Sesama FinPay'),
            Tab(text: 'Ke Rekening Bank'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar Pencarian
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.pillAll,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _contactQuery = v),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Cari Nama, No. HP, atau No. Rekening...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Favorit / Transaksi Terakhir
            Text('Kontak Favorit & Terakhir', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _recipientController.text =
                            '${contact['phone']} (${contact['name']})';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              contact['initials']!,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            contact['name']!.split(' ').first,
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Form Input Transfer Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Penerima & Nominal', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _recipientController,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Penerima',
                      prefixIcon: const Icon(
                        Icons.person_pin_rounded,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                    decoration: InputDecoration(
                      labelText: 'Nominal Transfer (Rp)',
                      prefixIcon: const Icon(
                        Icons.payments_rounded,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _noteController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Catatan Transfer (Opsional)',
                      prefixIcon: const Icon(
                        Icons.note_alt_rounded,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sumber Dana Info Card (Reaktif mengikuti WalletService)
            ValueListenableBuilder<WalletModel>(
              valueListenable: WalletService.instance.walletNotifier,
              builder: (context, wallet, _) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Sumber Dana: FinPay Cash',
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.rupiah(wallet.cashBalance),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processTransfer,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Lanjut Transfer Sekarang',
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
    );
  }
}
