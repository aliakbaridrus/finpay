/// Model data rekening bank & kartu tersimpan untuk koleksi `linked_accounts`
/// di Firebase Firestore (Bagian Tugas Pidi).
class LinkedAccountModel {
  const LinkedAccountModel({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.holderName,
    this.isPrimary = false,
    this.accountType = 'Bank',
    this.createdAt,
  });

  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String holderName;
  final bool isPrimary;
  final String accountType;
  final DateTime? createdAt;

  /// Empat digit terakhir nomor rekening/kartu.
  String get last4 => accountNumber.length >= 4
      ? accountNumber.substring(accountNumber.length - 4)
      : accountNumber;

  /// Tampilan nomor rekening yang disamarkan, mis. `BCA •••• 4821`.
  String get maskedTitle => '$bankName •••• $last4';

  LinkedAccountModel copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? accountNumber,
    String? holderName,
    bool? isPrimary,
    String? accountType,
    DateTime? createdAt,
  }) {
    return LinkedAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      isPrimary: isPrimary ?? this.isPrimary,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'holderName': holderName,
      'isPrimary': isPrimary,
      'accountType': accountType,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LinkedAccountModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return LinkedAccountModel(
      id: (map['id'] as String?) ??
          docId ??
          'acc_${DateTime.now().millisecondsSinceEpoch}',
      userId: (map['userId'] as String?) ?? 'finpay_user_01',
      bankName: (map['bankName'] as String?) ?? 'BCA',
      accountNumber: (map['accountNumber'] as String?) ?? '8801204821',
      holderName: (map['holderName'] as String?) ?? 'Reza Pratama',
      isPrimary: (map['isPrimary'] as bool?) ?? false,
      accountType: (map['accountType'] as String?) ?? 'Bank',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}
