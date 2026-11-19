import 'package:flutter/material.dart';

import 'cards_page.dart';

/// Halaman Penuh: Rekening & Kartu Terhubung (Mengarahkan ke CardsPage yang terintegrasi AccountService).
class LinkedAccountsPage extends StatelessWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CardsPage();
  }
}
