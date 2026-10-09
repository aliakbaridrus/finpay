import 'package:flutter/material.dart';

/// Konstanta spacing, radius, dan ukuran. Semua jarak di UI mengacu ke sini
/// sehingga tampilan dapat di-adjust dari satu tempat.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Padding horizontal halaman.
  static const double page = 16;

  /// Jarak vertikal antar section.
  static const double section = 24;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

abstract final class AppSizes {
  /// Lebar maksimum konten (agar tetap proporsional di tablet / web).
  static const double maxContentWidth = 480;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  static const double quickActionBox = 52;
  static const double serviceIconBox = 44;
  static const double transactionIconBox = 40;

  static const double bottomNavHeight = 68;
  static const double bottomNavCenterButton = 56;
}

abstract final class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
