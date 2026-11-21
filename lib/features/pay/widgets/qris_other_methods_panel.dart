import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Panel putih bagian bawah layar Scan QRIS ("Metode QRIS Lainnya")
/// menampilkan tombol aksi **Bayar** (menggunakan PIN) dan **Transfer** (QRIS Saya),
/// tanpa tombol Tap/NFC.
class QrisOtherMethodsPanel extends StatelessWidget {
  const QrisOtherMethodsPanel({
    super.key,
    required this.onBayarTap,
    required this.onTransferTap,
  });

  final VoidCallback onBayarTap;
  final VoidCallback onTransferTap;

  static const Color _qrisBlue = Color(0xFF00529C);
  static const Color _titleNavy = Color(0xFF0A3D7A);
  static const Color _cardBorder = Color(0xFFD9E1EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Metode QRIS Lainnya',
            style: AppTextStyles.h3.copyWith(
              color: _titleNavy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _QrisMethodCard(
                  label: 'Bayar',
                  icon: const _QrisBayarIcon(color: _qrisBlue),
                  borderColor: _cardBorder,
                  onTap: onBayarTap,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QrisMethodCard(
                  label: 'Transfer',
                  icon: const _QrisTransferIcon(color: _qrisBlue),
                  borderColor: _cardBorder,
                  onTap: onTransferTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrisMethodCard extends StatelessWidget {
  const _QrisMethodCard({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                height: 30,
                child: Center(child: icon),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: const Color(0xFF334155),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ikon kustom `Bayar` (`[Rp]` dengan frame siku QRIS biru).
class _QrisBayarIcon extends StatelessWidget {
  const _QrisBayarIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 28),
      painter: _QrisBayarPainter(color: color),
      child: SizedBox(
        width: 32,
        height: 28,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              'Rp',
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrisBayarPainter extends CustomPainter {
  const _QrisBayarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Siku QR kiri-atas hingga kiri-bawah
    final bracket = Path()
      ..moveTo(size.width * 0.45, 3)
      ..lineTo(3, 3)
      ..lineTo(3, size.height - 3)
      ..lineTo(size.width * 0.72, size.height - 3)
      ..lineTo(size.width * 0.72, size.height * 0.56);
    canvas.drawPath(bracket, strokePaint);

    // Titik blok QR di tengah dalam
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8.5, size.height - 13.5, 6.5, 6.5),
        const Radius.circular(1),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrisBayarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ikon kustom `Transfer` (kartu QRIS dengan tanda `Rp` di bagian bawah).
class _QrisTransferIcon extends StatelessWidget {
  const _QrisTransferIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 28),
      painter: _QrisTransferPainter(color: color),
      child: SizedBox(
        width: 32,
        height: 28,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'Rp',
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrisTransferPainter extends CustomPainter {
  const _QrisTransferPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Bentuk lembar kartu miring di bagian atas
    canvas.save();
    canvas.translate(size.width * 0.25, 2);
    canvas.rotate(-0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 15, 11),
        const Radius.circular(2.2),
      ),
      fillPaint,
    );
    canvas.restore();

    // Siku panah transfer di kanan bawah
    final path = Path()
      ..moveTo(size.width * 0.72, size.height * 0.44)
      ..lineTo(size.width * 0.80, size.height - 3)
      ..lineTo(size.width * 0.54, size.height - 3);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _QrisTransferPainter oldDelegate) =>
      oldDelegate.color != color;
}
