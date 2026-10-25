import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/services/wallet_service.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Bayar QRIS & Tarik Tunai FinPay terintegrasi WalletService (Bagian Ali).
class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  int _selectedMode = 0; // 0: Scan QRIS, 1: Kode Bayar / Tarik Tunai
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

  Future<void> _onProcessAction() async {
    final timeFormatted = TimeOfDay.now().format(context);

    if (_selectedMode == 0) {
      // Mode 0: Bayar dengan Scan QRIS via WalletService
      try {
        final trx = await WalletService.instance.payWithQris(
          merchantName: 'Kopi Kenangan Sudirman',
          amount: 45000,
          timeFormatted: timeFormatted,
        );
        if (!mounted) return;
        _showSuccessDialog(
          title: 'Pembayaran QRIS Sukses! 📱',
          amountText: CurrencyFormatter.rupiah(trx.amount, withSign: true),
          subtitle:
              'Merchant: Kopi Kenangan Sudirman\nNo. Ref: ${trx.referenceNumber}\nSisa Saldo Cash: ${CurrencyFormatter.rupiah(DummyData.cashBalance)}',
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } else {
      // Mode 1: Buat Kode Tarik Tunai ATM via WalletService
      try {
        final res = await WalletService.instance.createCashoutCode(
          amount: 200000,
          channelName: 'ATM Bersama / Indomaret',
          timeFormatted: timeFormatted,
        );
        if (!mounted) return;
        _showSuccessDialog(
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

  void _showSuccessDialog({
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
                        style:
                            AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Membuka Galeri Foto untuk QRIS...'),
                            ),
                          );
                        },
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Scanner Frame Container
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
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
                            width: 280,
                            height: 280,
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
                                  top: 20 + (_animationController.value * 240),
                                  child: Container(
                                    width: 240,
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
                          if (_selectedMode == 1)
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
                                    Icons.qr_code_2_rounded,
                                    size: 180,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(height: 4),
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
                    const SizedBox(height: AppSpacing.xl),
                    const PillBadge(
                      label: 'QRIS Resmi Berizin OJK & BI',
                      leadingIcon: Icons.verified_rounded,
                      backgroundColor: Color(0xFF1E2A55),
                      foregroundColor: AppColors.mint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _selectedMode == 0
                          ? 'Arahkan kamera ke QRIS merchant untuk membayar'
                          : 'Gunakan kode tarik tunai untuk penarikan di ATM / Retail',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
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
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ModeTab(
                          label: 'Tarik Tunai / Kode',
                          icon: Icons.payments_outlined,
                          isSelected: _selectedMode == 1,
                          onTap: () => setState(() => _selectedMode = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onProcessAction,
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        _selectedMode == 0
                            ? 'Bayar QRIS Merchant (Rp 45.000)'
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
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
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
