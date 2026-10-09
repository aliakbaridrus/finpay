import 'package:flutter/material.dart';

/// Item menu dengan ikon (dipakai di Quick Action & Layanan Keuangan).
class MenuItemData {
  const MenuItemData({
    required this.label,
    required this.icon,
    this.badge,
    this.backgroundColor,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final MenuBadge? badge;

  /// Warna latar kotak ikon. Null = memakai warna default widget.
  final Color? backgroundColor;

  /// Warna ikon. Null = memakai warna default widget.
  final Color? iconColor;
}

/// Badge kecil yang menempel di pojok ikon menu.
class MenuBadge {
  const MenuBadge.text(this.text, {required this.color}) : isDot = false;
  const MenuBadge.dot({required this.color})
      : text = null,
        isDot = true;

  final String? text;
  final Color color;
  final bool isDot;
}
