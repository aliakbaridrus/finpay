import 'package:flutter/material.dart';

/// Palet warna FinPay. Ubah nilai di sini untuk menyesuaikan tema
/// di seluruh aplikasi.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFE8EFFE);
  static const Color primarySoft = Color(0xFFF1F5FF);

  // Accent
  static const Color mint = Color(0xFF5EEAD4);
  static const Color mintLight = Color(0xFFE6FBF6);
  static const Color gold = Color(0xFFFACC15);
  static const Color goldLight = Color(0xFFFEF3C7);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEE2E2);

  // Neutral
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Dark card (banner pinjaman)
  static const Color navy = Color(0xFF0F1B3D);
  static const Color navyLight = Color(0xFF1E2A55);

  // Gradients
  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const LinearGradient loanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, navyLight],
  );
}
