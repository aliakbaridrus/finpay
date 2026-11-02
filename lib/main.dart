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

class FinPayApp extends StatelessWidget {
  const FinPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinPay',
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
      // Secara default (baik di HP maupun saat flutter run -d chrome), selalu membuka aplikasi FinPay.
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/admin': (context) => const AdminDashboardPage(),
      },
    );
  }
}
