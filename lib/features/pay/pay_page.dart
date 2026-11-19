import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/qris_model.dart';
import '../../data/services/qris_service.dart';
import '../../data/services/wallet_service.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/qris_code_card.dart';
import '../account/pages/my_qr_page.dart';
import 'widgets/qris_confirm_sheet.dart';
import 'widgets/qris_merchant_picker_sheet.dart';
import 'widgets/qris_receipt_sheet.dart';

/// Halaman Bayar QRIS, QRIS Saya, & Tarik Tunai FinPay terintegrasi QrisService & WalletService (Bagian Ali).
class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  int _selectedMode = 0; // 0: Scan QRIS, 1: QRIS Saya, 2: Tarik Tunai
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Alur lengkap pembayaran QRIS dari string EMVCo QRIS:
  /// 1. Parse & validasi CRC16 via [QrisService.scan]
  /// 2. Tampilkan lembar konfirmasi [showQrisConfirmSheet]
  /// 3. Potong saldo & catat transaksi via [WalletService.payWithQris]
  /// 4. Tampilkan struk digital [showQrisReceipt]
  Future<void> _handleScannedQrisString(String rawQris) async {
    final QrisPayload payload;
    try {
      payload = QrisService.instance.scan(rawQris);
    } on QrisFormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      return;
    }

    final approvedAmount = await showQrisConfirmSheet(context, payload);
    if (approvedAmount == null || !mounted) return;

    final timeFormatted = TimeOfDay.now().format(context);
    try {
      final fee = QrisService.instance.adminFee(approvedAmount);
      final trx = await WalletService.instance.payWithQris(
        merchantName: payload.merchantName,
        merchantCity: payload.merchantCity,
        nmid: payload.nmid,
        amount: approvedAmount,
        adminFee: fee,
        timeFormatted: timeFormatted,
      );
      if (!mounted) return;
      setState(() {});
      await showQrisReceipt(
        context,
        transaction: trx,
        payload: payload,
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openMerchantPicker() async {
    final merchant = await showQrisMerchantPicker(context);
    if (merchant == null || !mounted) return;
    await _handleScannedQrisString(merchant.qrisString);
  }

  Future<void> _showPasteQrisDialog() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        title: Text('Input / Tempel Kode QRIS', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tempel string payload QRIS EMVCo (diawali 000201... dan diakhiri checksum CRC16):',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '00020101021226...',
                border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proses QRIS'),
          ),
        ],
      ),
    );
    if (raw == null || raw.trim().isEmpty || !mounted) return;
    await _handleScannedQrisString(raw);
  }

  Future<void> _onProcessAction() async {
    if (_selectedMode == 0) {
      await _openMerchantPicker();
    } else if (_selectedMode == 1) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const MyQrPage()),
      );
      if (mounted) setState(() {});
    } else {
      final timeFormatted = TimeOfDay.now().format(context);
      try {
        final res = await WalletService.instance.createCashoutCode(
          amount: 200000,
          channelName: 'ATM Bersama / Indomaret',
          timeFormatted: timeFormatted,
        );
        if (!mounted) return;
        _showCashoutSuccessDialog(
          title: 'Kode Tarik Tunai Dibuat! 🏧',
          amountText: CurrencyFormatter.rupiah(-200000, withSign: true),
          subtitle:
              'Kode Penarikan: ${res['tokenCode']}\nNo. Ref: ${res['referenceNumber']}\nSisa Saldo Cash: ${CurrencyFormatter.rupiah(DummyData.cashBalance)}',
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _showCashoutSuccessDialog({
    required String title,
    required String amountText,
    required String subtitle,
  }) {
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
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              amountText,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.danger,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
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

  @override
  Widget build(BuildContext context) {
    final myQrisPayload = QrisService.instance.myQris();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayar QRIS & Tarik Tunai',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saldo Aktif: ${CurrencyFormatter.rupiah(DummyData.cashBalance)}',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Lampu Flash',
                        onPressed: () =>
                            setState(() => _isFlashOn = !_isFlashOn),
                        icon: Icon(
                          _isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _isFlashOn ? AppColors.gold : Colors.white,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Input / Tempel Kode QRIS',
                        onPressed: _showPasteQrisDialog,
                        icon: const Icon(
                          Icons.qr_code_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Pilih Merchant / Galeri QRIS',
                        onPressed: _openMerchantPicker,
                        icon: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    if (_selectedMode == 1)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: QrisCodeCard(
                          data: myQrisPayload.encode(),
                          merchantName: myQrisPayload.merchantName,
                          nmid: myQrisPayload.nmid,
                          size: 180,
                        ),
                      )
                    else
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: AppRadius.xlAll,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: CustomPaint(
                                painter:
                                    _QRScannerPainter(color: AppColors.primary),
                              ),
                            ),
                            if (_selectedMode == 0)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Positioned(
                                    top: 18 + (_animationController.value * 220),
                                    child: Container(
                                      width: 220,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.8),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (_selectedMode == 2)
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadius.lgAll,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.payments_rounded,
                                      size: 120,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '8819 2819 0192 4819',
                                      style: AppTextStyles.label
                                          .copyWith(letterSpacing: 2),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    const PillBadge(
                      label: 'QRIS Resmi Standar EMVCo BI & ASPI',
                      leadingIcon: Icons.verified_rounded,
                      backgroundColor: Color(0xFF1E2A55),
                      foregroundColor: AppColors.mint,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _selectedMode == 0
                          ? 'Arahkan kamera ke QRIS merchant atau pilih merchant uji coba'
                          : _selectedMode == 1
                              ? 'Tunjukkan QRIS kamu untuk menerima saldo dari bank / e-wallet lain'
                              : 'Gunakan kode tarik tunai untuk penarikan di ATM / Retail',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // Mode Selector Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ModeTab(
                          label: 'Scan QRIS',
                          icon: Icons.qr_code_scanner_rounded,
                          isSelected: _selectedMode == 0,
                          onTap: () => setState(() => _selectedMode = 0),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _ModeTab(
                          label: 'QRIS Saya',
                          icon: Icons.qr_code_2_rounded,
                          isSelected: _selectedMode == 1,
                          onTap: () => setState(() => _selectedMode = 1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _ModeTab(
                          label: 'Tarik Tunai',
                          icon: Icons.payments_outlined,
                          isSelected: _selectedMode == 2,
                          onTap: () => setState(() => _selectedMode = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onProcessAction,
                      icon: Icon(
                        _selectedMode == 0
                            ? Icons.qr_code_scanner_rounded
                            : _selectedMode == 1
                                ? Icons.open_in_full_rounded
                                : Icons.flash_on_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        _selectedMode == 0
                            ? 'Pilih & Scan QRIS Merchant'
                            : _selectedMode == 1
                                ? 'Atur Nominal / Terima Pembayaran QRIS'
                                : 'Buat Kode Tarik Tunai (Rp 200.000)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                        elevation: 4,
                      ),
                    ),
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

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillAll,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QRScannerPainter extends CustomPainter {
  _QRScannerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 30.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height)
        ..lineTo(cornerSize, size.height),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
