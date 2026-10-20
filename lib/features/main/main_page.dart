import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../account/account_page.dart';
import '../home/home_page.dart';
import 'widgets/finpay_bottom_nav_bar.dart';

/// Shell utama aplikasi yang memegang state bottom navigation.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const List<NavItemData> _navItems = [
    NavItemData(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    NavItemData(
      label: 'Riwayat',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    NavItemData(
      label: 'Bayar',
      icon: Icons.qr_code_scanner_rounded,
      activeIcon: Icons.qr_code_scanner_rounded,
    ),
    NavItemData(
      label: 'Keuangan',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
    NavItemData(
      label: 'Akun',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  Widget _buildPage(int index) {
    if (index == 0) return const HomePage();
    if (index == 4) return const AccountPage();
    // Placeholder untuk halaman lain yang belum dibuat.
    return Center(
      child: Text(_navItems[index].label, style: AppTextStyles.h2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_navItems.length, _buildPage),
      ),
      bottomNavigationBar: FinPayBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
