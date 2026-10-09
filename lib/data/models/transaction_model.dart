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
    this.status = 'Sukses',
  });

  final String title;

  /// Teks tanggal sudah diformat, mis. "24 Okt, 18:20".
  final String dateTime;
  final String channel;

  /// Positif = uang masuk, negatif = uang keluar.
  final int amount;
  final IconData icon;
  final TransactionType type;
  final String status;

  bool get isIncoming => amount >= 0;
  String get subtitle => '$dateTime • $channel';
}
