/// Data dummy khusus halaman Akun.
///
/// Dipisah dari `dummy_data.dart` supaya tidak bentrok dengan perubahan
/// teman-teman di file bersama. Ganti dengan data dari API saat integrasi.
abstract final class AccountDummy {
  static const String email = 'reza.pratama@email.com';
  static const String memberSince = 'Jan 2024';
  static const int monthlyTransactions = 24;

  // Level membership berikutnya
  static const String nextTierName = 'FinPay Elite';
  static const int nextTierPoints = 2000;

  // Referral
  static const String referralCode = 'FINPAY-REZA25';
  static const int referralBonus = 500;

  static const int dailyLimit = 50000000;
  static const String appVersion = '1.0.0';
}
