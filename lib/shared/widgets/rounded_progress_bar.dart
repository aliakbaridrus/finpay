import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Progress bar sederhana yang membulat.
///
/// Jika [remainderColor] diisi, sisa bar memakai warna tersebut
/// (dipakai untuk visual pemasukan vs pengeluaran).
class RoundedProgressBar extends StatelessWidget {
  const RoundedProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primaryLight,
    this.remainderColor,
  });

  /// Nilai 0.0 - 1.0
  final double value;
  final double height;
  final Color color;
  final Color backgroundColor;
  final Color? remainderColor;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: AppRadius.pillAll,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              flex: (progress * 1000).round(),
              child: ColoredBox(color: color),
            ),
            Expanded(
              flex: ((1 - progress) * 1000).round(),
              child: ColoredBox(color: remainderColor ?? backgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
