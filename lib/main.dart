import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/main/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FinPayApp());
}

class FinPayApp extends StatefulWidget {
  const FinPayApp({super.key});

  @override
  State<FinPayApp> createState() => _FinPayAppState();
}

class _FinPayAppState extends State<FinPayApp> {
  // Jika dibuka di Web/Desktop, default membuka Admin Web Portal
  bool _isAdminMode = kIsWeb;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinPay & Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Batasi skala teks sistem agar layout tetap rapi di semua perangkat.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child!,
        );
      },
      home: LayoutBuilder(
        builder: (context, constraints) {
          // Jika lebar layar >= 800px dan mode admin aktif, tampilkan Admin Web Portal
          final isLargeScreen = constraints.maxWidth >= 800;

          if (isLargeScreen && _isAdminMode) {
            return AdminDashboardPage(
              onSwitchToMobile: () => setState(() => _isAdminMode = false),
            );
          }

          return Stack(
            children: [
              const MainPage(),
              // Tombol Floating Switcher di Desktop/Web untuk kembali ke Admin Web
              if (isLargeScreen)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () => setState(() => _isAdminMode = true),
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: const Text('Mode Admin Web'),
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
