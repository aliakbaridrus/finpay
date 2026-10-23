import 'package:flutter/material.dart';

import 'pages/about_app_page.dart';
import 'pages/help_center_page.dart';
import 'pages/language_settings_page.dart';
import 'pages/legal_terms_page.dart';
import 'pages/linked_accounts_page.dart';
import 'pages/notifications_settings_page.dart';
import 'pages/profile_detail_page.dart';
import 'pages/security_settings_page.dart';
import 'pages/theme_settings_page.dart';

/// Helper navigasi penuh (Full Page Navigation) untuk menu di bagian Akun dengan animasi transisi.
abstract class AccountNavigationHelper {
  static void openFeature(BuildContext context, String title) {
    final lower = title.toLowerCase();

    Widget page;
    if (lower.contains('data diri') || lower.contains('profil')) {
      page = const ProfileDetailPage();
    } else if (lower.contains('rekening') || lower.contains('kartu')) {
      page = const LinkedAccountsPage();
    } else if (lower.contains('keamanan') || lower.contains('pin')) {
      page = const SecuritySettingsPage();
    } else if (lower.contains('notifikasi')) {
      page = const NotificationsSettingsPage();
    } else if (lower.contains('bahasa') || lower.contains('language')) {
      page = const LanguageSettingsPage();
    } else if (lower.contains('tampilan') || lower.contains('tema')) {
      page = const ThemeSettingsPage();
    } else if (lower.contains('bantuan') || lower.contains('fincare')) {
      page = const HelpCenterPage();
    } else if (lower.contains('syarat') || lower.contains('kebijakan')) {
      page = const LegalTermsPage();
    } else if (lower.contains('tentang')) {
      page = const AboutAppPage();
    } else {
      page = const ProfileDetailPage();
    }

    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.08, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeIn);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}
