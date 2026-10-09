import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi aplikasi berbasis Plus Jakarta Sans.
abstract final class AppTextStyles {
  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  // Display / angka besar
  static TextStyle get displayLarge =>
      _base(size: 32, weight: FontWeight.w800, height: 1.2);
  static TextStyle get displayMedium =>
      _base(size: 22, weight: FontWeight.w800, height: 1.2);

  // Heading
  static TextStyle get h1 => _base(size: 20, weight: FontWeight.w800);
  static TextStyle get h2 => _base(size: 18, weight: FontWeight.w700);
  static TextStyle get h3 => _base(size: 15, weight: FontWeight.w700);

  // Body
  static TextStyle get bodyLarge => _base(size: 14, weight: FontWeight.w600);
  static TextStyle get body => _base(size: 13, weight: FontWeight.w500);
  static TextStyle get bodySmall =>
      _base(size: 12, color: AppColors.textSecondary);

  // Caption & label
  static TextStyle get caption =>
      _base(size: 11, weight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get label => _base(size: 12, weight: FontWeight.w600);
  static TextStyle get labelSmall => _base(size: 10, weight: FontWeight.w700);

  static TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme();
}
