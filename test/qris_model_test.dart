import 'package:finpay/data/models/qris_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const merchant = QrisPayload(
    merchantName: 'Kopi Kenangan Sudirman',
    merchantCity: 'Jakarta',
    nmid: 'ID1020023912901',
  );

  group('QrisCrc', () {
    test('menghasilkan CRC16/CCITT-FALSE standar', () {
      expect(QrisCrc.crc16('123456789'), '29B1');
    });
  });

  group('QrisPayload.encode', () {
    test('QRIS statis memakai point of initiation 11 dan tanpa nominal', () {
      final qr = merchant.encode();
      expect(qr.startsWith('000201010211'), isTrue);
      expect(qr.contains('5303360'), isTrue);
      expect(qr.contains('5802ID'), isTrue);
      expect(merchant.isDynamic, isFalse);
    });

    test('QRIS dinamis memakai 12 dan menyimpan nominal', () {
      final qr = merchant.copyWith(amount: 45000).encode();
      expect(qr.startsWith('000201010212'), isTrue);
      expect(qr.contains('540545000'), isTrue);
    });

    test('diakhiri tag CRC 6304 + 4 digit heksa', () {
      final qr = merchant.encode();
      expect(RegExp(r'6304[0-9A-F]{4}$').hasMatch(qr), isTrue);
    });
  });

  group('QrisPayload.parse', () {
    test('round-trip QRIS dinamis mengembalikan data yang sama', () {
      final qr = merchant
          .copyWith(
            amount: 125000,
            referenceLabel: 'INV-0001',
            terminalLabel: 'KASIR01',
          )
          .encode();
      final parsed = QrisPayload.parse(qr);

      expect(parsed.merchantName, 'Kopi Kenangan Sudirman');
      expect(parsed.merchantCity, 'Jakarta');
      expect(parsed.nmid, 'ID1020023912901');
      expect(parsed.amount, 125000);
      expect(parsed.isDynamic, isTrue);
      expect(parsed.referenceLabel, 'INV-0001');
      expect(parsed.terminalLabel, 'KASIR01');
    });

    test('round-trip QRIS statis tidak memiliki nominal', () {
      final parsed = QrisPayload.parse(merchant.encode());
      expect(parsed.amount, isNull);
      expect(parsed.isDynamic, isFalse);
    });

    test('menolak string yang bukan QRIS', () {
      expect(
        () => QrisPayload.parse('https://example.com'),
        throwsA(isA<QrisFormatException>()),
      );
    });

    test('menolak QRIS dengan checksum yang salah', () {
      final qr = merchant.encode();
      final tampered = '${qr.substring(0, qr.length - 4)}0000';
      expect(
        () => QrisPayload.parse(tampered),
        throwsA(isA<QrisFormatException>()),
      );
    });

    test('menolak QRIS yang nominalnya dimodifikasi', () {
      final qr = merchant.copyWith(amount: 10000).encode();
      final tampered = qr.replaceFirst('540510000', '540599999');
      expect(
        () => QrisPayload.parse(tampered),
        throwsA(isA<QrisFormatException>()),
      );
    });
  });
}
