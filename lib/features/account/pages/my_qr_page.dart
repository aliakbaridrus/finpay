import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy/dummy_data.dart';
import '../widgets/sub_page_scaffold.dart';

/// QR Saya: kartu untuk menerima pembayaran.
/// QR di sini hanya ilustrasi (pola dummy), bukan kode yang bisa dipindai.
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key});

  void _copyNumber(BuildContext context) {
    // Kode yang benar:
    Clipboard.setData(ClipboardData(text: DummyData.phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor FinPay disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'QR Saya',
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.balanceGradient,
            borderRadius: AppRadius.xlAll,
            boxShadow: AppShadows.glow(AppColors.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(
                  'Scan untuk membayar ke',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DummyData.userName,
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(painter: _FakeQrPainter()),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  DummyData.phoneNumber,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Contoh tampilan, bukan QR asli',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyNumber(context),
                icon: const Icon(Icons.copy_rounded, size: AppSizes.iconMd),
                label: Text(
                  'Salin Nomor',
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bagikan belum tersedia (demo)')),
                ),
                icon: const Icon(Icons.ios_share_rounded, size: AppSizes.iconMd),
                label: Text(
                  'Bagikan',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Menggambar pola mirip QR (3 kotak sudut + isi pseudo-acak yang tetap).
class _FakeQrPainter extends CustomPainter {
  static const int _cells = 25;

  bool _inFinder(int x, int y) {
    final inX = x < 7 || x >= _cells - 7;
    final inY = y < 7 || y >= _cells - 7;
    // Tiga sudut: kiri-atas, kanan-atas, kiri-bawah (kanan-bawah kosong).
    return inX && inY && !(x >= _cells - 7 && y >= _cells - 7);
  }

  bool _finderFilled(int x, int y) {
    final lx = x < 7 ? x : x - (_cells - 7);
    final ly = y < 7 ? y : y - (_cells - 7);
    final ring = lx == 0 || lx == 6 || ly == 0 || ly == 6;
    final core = lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4;
    return ring || core;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _cells;
    final paint = Paint()..color = AppColors.textPrimary;

    for (var y = 0; y < _cells; y++) {
      for (var x = 0; x < _cells; x++) {
        final filled = _inFinder(x, y)
            ? _finderFilled(x, y)
            : (x * 7 + y * 13 + x * y) % 3 == 0;
        if (!filled) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            Radius.circular(cell * 0.2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
