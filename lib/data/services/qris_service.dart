import '../dummy/dummy_data.dart';
import '../models/qris_model.dart';

/// Service logika QRIS FinPay (Bagian Tugas Ali).
///
/// Bertugas membuat QRIS milik pengguna, membaca hasil scan,
/// dan memvalidasi nominal sebelum diteruskan ke [WalletService].
class QrisService {
  QrisService._();
  static final QrisService instance = QrisService._();

  /// Nominal minimum & maksimum per transaksi QRIS.
  static const int minAmount = 1000;
  static const int maxAmount = 10000000;

  /// NMID simulasi milik pengguna, diturunkan dari nomor HP.
  String get myNmid {
    final digits = DummyData.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final tail = digits.length > 9 ? digits.substring(digits.length - 9) : digits;
    return 'ID10${tail.padLeft(9, '0')}';
  }

  /// QRIS milik pengguna untuk menerima uang.
  /// - [amount] kosong = QRIS statis, pembayar mengisi nominal sendiri.
  /// - [amount] terisi = QRIS dinamis dengan nominal terkunci.
  QrisPayload myQris({int? amount, String? referenceLabel}) {
    return QrisPayload(
      merchantName: DummyData.userName,
      merchantCity: 'Jakarta',
      nmid: myNmid,
      merchantCategoryCode: '6012',
      amount: (amount != null && amount > 0) ? amount : null,
      referenceLabel: referenceLabel,
      terminalLabel: 'FINPAYUSER',
    );
  }

  /// Membaca string hasil scan. Melempar [QrisFormatException] bila tidak valid.
  QrisPayload scan(String raw) {
    final payload = QrisPayload.parse(raw);
    if (payload.nmid == myNmid) {
      throw const QrisFormatException(
        'Tidak bisa membayar ke QRIS milik sendiri.',
      );
    }
    return payload;
  }

  /// Menentukan nominal akhir yang akan dibayar.
  ///
  /// QRIS dinamis memakai nominal di dalam QR (nominal input diabaikan),
  /// QRIS statis memakai [enteredAmount] dari pengguna.
  int resolveAmount(QrisPayload payload, {int? enteredAmount}) {
    final amount = payload.isDynamic ? payload.amount! : (enteredAmount ?? 0);
    validateAmount(amount);
    return amount;
  }

  void validateAmount(int amount) {
    if (amount < minAmount) {
      throw const QrisFormatException('Nominal minimal pembayaran Rp 1.000.');
    }
    if (amount > maxAmount) {
      throw const QrisFormatException(
        'Nominal melebihi batas QRIS Rp 10.000.000 per transaksi.',
      );
    }
  }

  /// Biaya layanan QRIS untuk pembayar. FinPay menggratiskan seluruh biaya.
  int adminFee(int amount) => 0;
}
