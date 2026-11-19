/// Model data dompet pengguna untuk koleksi `wallets` di Firebase Firestore.
class WalletModel {
  const WalletModel({
    required this.userId,
    required this.cashBalance,
    required this.savingBalance,
    this.updatedAt,
  });

  final String userId;
  final int cashBalance;
  final int savingBalance;
  final DateTime? updatedAt;

  /// Total kekayaan aset (Saldo Kas + Saldo Tabungan).
  int get totalWealth => cashBalance + savingBalance;

  WalletModel copyWith({
    String? userId,
    int? cashBalance,
    int? savingBalance,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      cashBalance: cashBalance ?? this.cashBalance,
      savingBalance: savingBalance ?? this.savingBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Konversi ke Map untuk disimpan ke dokumen Firestore `wallets/{uid}`.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cashBalance': cashBalance,
      'savingBalance': savingBalance,
      'totalWealth': totalWealth,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Buat instance `WalletModel` dari dokumen Firestore `wallets/{uid}`.
  factory WalletModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WalletModel(
      userId: (map['userId'] as String?) ?? docId ?? 'default_user',
      cashBalance: (map['cashBalance'] as num?)?.toInt() ?? 0,
      savingBalance: (map['savingBalance'] as num?)?.toInt() ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }
}
