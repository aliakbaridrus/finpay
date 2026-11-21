import 'package:flutter/material.dart';

/// Watermark logo `QRIS SUPPORTED` transparan di bagian bawah area kamera
/// sesuai standar tampilan scanner QRIS perbankan Indonesia.
class QrisSupportedWatermark extends StatelessWidget {
  const QrisSupportedWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeColor = Colors.white.withValues(alpha: 0.78);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 36,
          child: CustomPaint(
            painter: _QrisBracketPainter(color: badgeColor),
            child: Center(
              child: Text(
                'QRIS',
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SUPPORTED',
          style: TextStyle(
            color: badgeColor,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }
}

class _QrisBracketPainter extends CustomPainter {
  const _QrisBracketPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const cornerW = 14.0;
    const cornerH = 10.0;

    // Sudut kiri atas
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerH)
        ..lineTo(0, 0)
        ..lineTo(cornerW, 0),
      paint,
    );

    // Sudut kanan bawah
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerW, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrisBracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
