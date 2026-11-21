import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Fallback / Native camera preview untuk lingkungan non-Web dan pengujian widget.
Widget buildPlatformQrisCamera({
  required bool isActive,
  required bool isFlashOn,
  VoidCallback? onTapViewport,
}) {
  return _SimulatedCameraFeed(
    isActive: isActive,
    isFlashOn: isFlashOn,
    onTapViewport: onTapViewport,
  );
}

class _SimulatedCameraFeed extends StatelessWidget {
  const _SimulatedCameraFeed({
    required this.isActive,
    required this.isFlashOn,
    this.onTapViewport,
  });

  final bool isActive;
  final bool isFlashOn;
  final VoidCallback? onTapViewport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapViewport,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Latar visual lensa kamera realistis
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 1.35,
                colors: isFlashOn
                    ? const [
                        Color(0xFF7C6248),
                        Color(0xFF4B3D30),
                        Color(0xFF231E1A),
                      ]
                    : const [
                        Color(0xFF5C4B3B),
                        Color(0xFF352C25),
                        Color(0xFF1A1614),
                      ],
              ),
            ),
          ),
          // Efek pencahayaan ambient permukaan objek kamera
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD99B66).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kamera QRIS Aktif • Ketuk layar untuk pindai merchant',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
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
