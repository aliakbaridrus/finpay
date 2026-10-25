import 'package:flutter/material.dart';

enum TransactionType { income, expense, saving }

enum TransactionFilter {
  all('Semua'),
  income('Pemasukan'),
  expense('Pengeluaran'),
  saving('Tabungan');

  const TransactionFilter(this.label);
  final String label;

  bool matches(TransactionModel trx) => switch (this) {
        TransactionFilter.all => true,
        TransactionFilter.income => trx.type == TransactionType.income,
        TransactionFilter.expense => trx.type == TransactionType.expense,
        TransactionFilter.saving => trx.type == TransactionType.saving,
      };
}

class TransactionModel {
  const TransactionModel({
    required this.title,
    required this.dateTime,
    required this.channel,
    required this.amount,
    required this.icon,
    required this.type,
    this.userId = 'finpay_user_01',
    this.status = 'Sukses',
    this.referenceNumber = 'FPX-8920192381',
    this.category = 'Keuangan',
    this.adminFee = 0,
    this.note,
    this.dateGroup = '24 Oktober 2024',
    this.createdAt,
  });

  final String userId;
  final String title;

  /// Teks tanggal sudah diformat, mis. "24 Okt, 18:20".
  final String dateTime;
  final String channel;

  /// Positif = uang masuk, negatif = uang keluar.
  final int amount;
  final IconData icon;
  final TransactionType type;
  final String status;
  final String referenceNumber;
  final String category;
  final int adminFee;
  final String? note;
  final String dateGroup;
  final DateTime? createdAt;

  bool get isIncoming => amount >= 0;
  String get subtitle => '$dateTime • $channel';

  /// Konversi ke Map untuk disimpan ke koleksi `transactions` di Firebase Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'dateTime': dateTime,
      'channel': channel,
      'amount': amount,
      'type': type.name,
      'status': status,
      'referenceNumber': referenceNumber,
      'category': category,
      'adminFee': adminFee,
      'note': note,
      'dateGroup': dateGroup,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Buat `TransactionModel` dari dokumen Firebase Firestore.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final typeName = (map['type'] as String?) ?? 'expense';
    final parsedType = TransactionType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => TransactionType.expense,
    );

    final category = (map['category'] as String?) ?? 'Keuangan';

    return TransactionModel(
      userId: (map['userId'] as String?) ?? 'finpay_user_01',
      title: (map['title'] as String?) ?? 'Transaksi FinPay',
      dateTime: (map['dateTime'] as String?) ?? 'Hari Ini',
      channel: (map['channel'] as String?) ?? 'FinPay',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      icon: _iconForCategory(category, parsedType),
      type: parsedType,
      status: (map['status'] as String?) ?? 'Sukses',
      referenceNumber: (map['referenceNumber'] as String?) ?? 'FPX-000000',
      category: category,
      adminFee: (map['adminFee'] as num?)?.toInt() ?? 0,
      note: map['note'] as String?,
      dateGroup: (map['dateGroup'] as String?) ?? 'Hari Ini',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  static IconData _iconForCategory(String category, TransactionType type) {
    final lower = category.toLowerCase();
    if (lower.contains('isi saldo') || lower.contains('top up')) {
      return Icons.add_circle_outline_rounded;
    } else if (lower.contains('transfer')) {
      return Icons.swap_horiz_rounded;
    } else if (lower.contains('tabungan')) {
      return Icons.savings_outlined;
    } else if (lower.contains('qris') || lower.contains('merchant')) {
      return Icons.qr_code_scanner_rounded;
    } else if (lower.contains('tarik')) {
      return Icons.payments_outlined;
    } else if (lower.contains('pinjaman')) {
      return Icons.account_balance_wallet_outlined;
    }
    return type == TransactionType.income
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
  }
}
