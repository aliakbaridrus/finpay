import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finpay/main.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Beranda menampilkan sapaan dan saldo', (tester) async {
    await tester.pumpWidget(const FinPayApp());
    await tester.pump();

    expect(find.textContaining('Halo, Reza Pratama'), findsOneWidget);
    expect(find.text('Rp 14.850.000'), findsOneWidget);
  });

  // Surface dibuat sangat tinggi agar seluruh section ter-render,
  // sehingga overflow di bagian mana pun akan terdeteksi.
  for (final width in [320.0, 360.0, 390.0, 430.0, 768.0]) {
    testWidgets('Tidak ada overflow pada lebar $width', (tester) async {
      tester.view.physicalSize = Size(width, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const FinPayApp());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Keamanan Terjamin FinPay'), findsOneWidget);
    });
  }

  testWidgets('Filter transaksi bekerja', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FinPayApp());
    await tester.pump();

    expect(find.text('Transfer ke Budi Santoso'), findsOneWidget);

    await tester.tap(find.text('Pemasukan').last);
    await tester.pumpAndSettle();

    expect(find.text('Transfer ke Budi Santoso'), findsNothing);
    expect(find.text('Top Up QRIS Admin'), findsOneWidget);
  });
}
