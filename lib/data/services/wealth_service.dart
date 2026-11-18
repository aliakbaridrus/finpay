import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_colors.dart';
import '../dummy/dummy_data.dart';
import '../models/transaction_model.dart';
import '../models/wealth_models.dart';
import 'transaction_service.dart';
import 'wallet_service.dart';

/// Service Backend Produk Keuangan, Tabungan Impian, Pinjaman, Promo, & Cash Flow (Bagian Tugas Pidi).
///
/// Mengelola koleksi:
/// 1. `saving_goals` (Target menabung, setor tabungan, & tarik dana tabungan)
/// 2. `loans` (Pengajuan pencairan pinjaman instan & pembayaran cicilan bulanan)
/// 3. `promos` (Daftar voucher promo & klaim promo)
/// 4. Rekap Cash Flow & E-Statement (Perhitungan pemasukan vs pengeluaran & skor kesehatan finansial)
class WealthService {
  WealthService._();
  static final WealthService instance = WealthService._();

  /// Daftar target menabung yang reaktif.
  final ValueNotifier<List<SavingGoalModel>> savingGoalsNotifier =
      ValueNotifier<List<SavingGoalModel>>([
    const SavingGoalModel(
      id: 'goal_japan_01',
      userId: 'finpay_user_01',
      title: 'Liburan ke Jepang ✈️',
      category: 'Impian',
      currentAmount: 7500000,
      targetAmount: 15000000,
      monthlyDebit: 500000,
      eta: 'Mei 2025',
      colorHex: 0xFF2563EB,
    ),
    const SavingGoalModel(
      id: 'goal_emergency_02',
      userId: 'finpay_user_01',
      title: 'Dana Darurat 6 Bulan 🛡️',
      category: 'Keamanan',
      currentAmount: 8000000,
      targetAmount: 10000000,
      monthlyDebit: 1000000,
      eta: 'Desember 2024',
      colorHex: 0xFF5EEAD4,
    ),
    const SavingGoalModel(
      id: 'goal_laptop_03',
      userId: 'finpay_user_01',
      title: 'Beli Laptop Workstation 💻',
      category: 'Impian',
      currentAmount: 3000000,
      targetAmount: 12000000,
      monthlyDebit: 750000,
      eta: 'Agustus 2025',
      colorHex: 0xFFFACC15,
    ),
  ]);

  /// Daftar pinjaman aktif pengguna.
  final ValueNotifier<List<LoanModel>> activeLoansNotifier =
      ValueNotifier<List<LoanModel>>([
    const LoanModel(
      id: 'loan_initial_01',
      userId: 'finpay_user_01',
      principalAmount: 5000000,
      tenorMonths: 6,
      monthlyInstallment: 878333,
      paidMonths: 1,
      referenceNumber: 'FPX-90123849',
      status: 'Aktif',
    ),
  ]);

  /// Daftar voucher promo & status klaimnya.
  final ValueNotifier<List<PromoModel>> promosNotifier =
      ValueNotifier<List<PromoModel>>([
    const PromoModel(
      id: 'promo_qris_50',
      title: 'Cashback 50% QRIS Indomaret & Alfamart',
      description:
          'Maksimal cashback Rp 10.000 dengan minimal belanja Rp 20.000 di seluruh gerai Indomaret & Alfamart.',
      code: 'FINQRIS50',
      category: 'Cashback',
      validity: 'Berlaku s.d 31 Oktober 2024',
      discountAmount: 10000,
      icon: Icons.qr_code_2_rounded,
      color: AppColors.primary,
    ),
    const PromoModel(
      id: 'promo_pln_15',
      title: 'Diskon Tagihan PLN & PDAM Rp 15.000',
      description:
          'Potongan langsung Rp 15.000 untuk pembayaran tagihan PLN dan Air PDAM via FinPay.',
      code: 'HEMATPLN',
      category: 'Diskon Tagihan',
      validity: 'Berlaku s.d 15 November 2024',
      discountAmount: 15000,
      icon: Icons.bolt_rounded,
      color: AppColors.gold,
    ),
    const PromoModel(
      id: 'promo_invest_25',
      title: 'Bonus Unit Reksa Dana Rp 25.000',
      description:
          'Top Up investasi Reksa Dana Pasar Uang min. Rp 500.000 dan dapatkan unit bonus gratis.',
      code: 'INVESTBONUS',
      category: 'Investasi',
      validity: 'Berlaku s.d 30 November 2024',
      discountAmount: 25000,
      icon: Icons.trending_up_rounded,
      color: Color(0xFF0F766E),
    ),
  ]);

  List<SavingGoalModel> get savingGoals => savingGoalsNotifier.value;
  List<LoanModel> get activeLoans => activeLoansNotifier.value;
  List<PromoModel> get promos => promosNotifier.value;

  // ==================== 1. TABUNGAN IMPIAN (`saving_goals`) ====================

  /// Membuat target menabung baru dan menyimpannya ke koleksi `saving_goals` di Firestore.
  Future<SavingGoalModel> createSavingGoal({
    required String title,
    required int targetAmount,
    int? monthlyDebit,
    String category = 'Impian',
    String eta = 'Desember 2025',
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw Exception('Nama target menabung tidak boleh kosong.');
    }
    if (targetAmount < 100000) {
      throw Exception('Target menabung minimal Rp 100.000.');
    }

    final suggestedMonthly = monthlyDebit ?? (targetAmount / 12).round();
    final newGoal = SavingGoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: cleanTitle,
      category: category,
      currentAmount: 0,
      targetAmount: targetAmount,
      monthlyDebit: suggestedMonthly,
      eta: eta,
      colorHex: 0xFF2563EB,
      createdAt: DateTime.now(),
    );

    final updated = List<SavingGoalModel>.from(savingGoals)..insert(0, newGoal);
    savingGoalsNotifier.value = updated;
    await _syncSavingGoalToFirestore(newGoal);
    return newGoal;
  }

  /// Setor dana dari Saldo FinPay Cash ke Target Menabung tertentu.
  Future<TransactionModel> depositToGoal({
    required String goalId,
    required int amount,
    required String timeFormatted,
  }) async {
    final index = savingGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) {
      throw Exception('Target tabungan tidak ditemukan.');
    }
    final goal = savingGoals[index];

    final trx = await WalletService.instance.depositToSaving(
      amount: amount,
      goalTitle: goal.title,
      timeFormatted: timeFormatted,
    );

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    );
    final updatedList = List<SavingGoalModel>.from(savingGoals);
    updatedList[index] = updatedGoal;
    savingGoalsNotifier.value = updatedList;

    await _syncSavingGoalToFirestore(updatedGoal);
    return trx;
  }

  /// Tarik dana dari Target Menabung kembali ke Saldo FinPay Cash.
  Future<TransactionModel> withdrawFromGoal({
    required String goalId,
    required int amount,
    required String timeFormatted,
  }) async {
    if (amount <= 0) {
      throw Exception('Nominal penarikan tabungan harus lebih dari Rp 0.');
    }
    final index = savingGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) {
      throw Exception('Target tabungan tidak ditemukan.');
    }
    final goal = savingGoals[index];

    if (amount > goal.currentAmount) {
      throw Exception('Saldo pada target "${goal.title}" tidak mencukupi.');
    }
    if (amount > DummyData.savingBalance) {
      throw Exception('Saldo Tabungan FinPay kamu tidak mencukupi.');
    }

    await WalletService.instance.updateBalance(
      cashDelta: amount,
      savingDelta: -amount,
    );

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount - amount,
    );
    final updatedList = List<SavingGoalModel>.from(savingGoals);
    updatedList[index] = updatedGoal;
    savingGoalsNotifier.value = updatedList;

    final referenceNumber =
        'FPX-SV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final trx = TransactionModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: 'Tarik Tabungan: ${goal.title}',
      dateTime: 'Hari Ini, $timeFormatted',
      channel: 'Tabungan FinPay',
      amount: amount,
      icon: Icons.savings_outlined,
      type: TransactionType.income,
      referenceNumber: referenceNumber,
      category: 'Tabungan',
      dateGroup: 'Hari Ini',
      note: 'Pencairan dana tabungan (${goal.title}) ke Saldo Cash',
    );

    await TransactionService.instance.addTransaction(trx);
    await _syncSavingGoalToFirestore(updatedGoal);
    return trx;
  }

  // ==================== 2. PINJAMAN & PROMO (`loans` & `promos`) ====================

  /// Mengajukan pencairan Pinjaman Instan FinPay Loan, menambah Saldo Cash,
  /// dan menyimpan kontrak pinjaman ke koleksi `loans` di Firestore.
  Future<({LoanModel loan, TransactionModel transaction})> applyLoan({
    required int amount,
    required int tenorMonths,
    required String timeFormatted,
  }) async {
    final res = await WalletService.instance.disburseLoan(
      amount: amount,
      tenorMonths: tenorMonths,
      timeFormatted: timeFormatted,
    );

    final newLoan = LoanModel(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      userId: FirebaseFirestoreConfig.defaultUserId,
      principalAmount: amount,
      tenorMonths: tenorMonths,
      monthlyInstallment: res.monthlyInstallment,
      paidMonths: 0,
      referenceNumber: res.transaction.referenceNumber,
      status: 'Aktif',
      createdAt: DateTime.now(),
    );

    final updated = List<LoanModel>.from(activeLoans)..insert(0, newLoan);
    activeLoansNotifier.value = updated;
    await _syncLoanToFirestore(newLoan);

    return (loan: newLoan, transaction: res.transaction);
  }

  /// Membayar 1 bulan cicilan pinjaman aktif dari Saldo FinPay Cash.
  Future<({LoanModel loan, TransactionModel transaction})> payLoanInstallment({
    required String loanId,
    required String timeFormatted,
  }) async {
    final index = activeLoans.indexWhere((l) => l.id == loanId);
    if (index == -1) {
      throw Exception('Data pinjaman tidak ditemukan.');
    }
    final loan = activeLoans[index];
    if (loan.isCompleted) {
      throw Exception('Pinjaman ini sudah lunas.');
    }
    if (loan.monthlyInstallment > DummyData.cashBalance) {
      throw Exception('Saldo FinPay Cash tidak cukup untuk membayar cicilan!');
    }

    await WalletService.instance.updateBalance(
      cashDelta: -loan.monthlyInstallment,
    );

    final nextPaidMonths = loan.paidMonths + 1;
    final isNowLunas = nextPaidMonths >= loan.tenorMonths;
    final updatedLoan = loan.copyWith(
      paidMonths: nextPaidMonths,
      status: isNowLunas ? 'Lunas' : 'Aktif',
    );

    final updatedList = List<LoanModel>.from(activeLoans);
    updatedList[index] = updatedLoan;
    activeLoansNotifier.value = updatedList;

    final referenceNumber =
        'FPX-LN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final trx = TransactionModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: 'Bayar Cicilan FinPay Loan ($nextPaidMonths/${loan.tenorMonths})',
      dateTime: 'Hari Ini, $timeFormatted',
      channel: 'FinPay Loan OJK',
      amount: -loan.monthlyInstallment,
      icon: Icons.request_quote_outlined,
      type: TransactionType.expense,
      referenceNumber: referenceNumber,
      category: 'Pinjaman',
      dateGroup: 'Hari Ini',
      note:
          'Pembayaran cicilan ke-$nextPaidMonths dari ${loan.tenorMonths} (${loan.referenceNumber})',
    );

    await TransactionService.instance.addTransaction(trx);
    await _syncLoanToFirestore(updatedLoan);

    return (loan: updatedLoan, transaction: trx);
  }

  /// Klaim kode promo/voucher & sinkronkan ke koleksi `promos` di Firestore.
  Future<PromoModel> claimPromo(String promoId) async {
    final index = promos.indexWhere((p) => p.id == promoId);
    if (index == -1) {
      throw Exception('Promo tidak ditemukan.');
    }

    final updatedPromo = promos[index].copyWith(isClaimed: true);
    final updatedList = List<PromoModel>.from(promos);
    updatedList[index] = updatedPromo;
    promosNotifier.value = updatedList;

    await _syncPromoToFirestore(updatedPromo);
    return updatedPromo;
  }

  // ==================== 3. CASH FLOW & E-STATEMENT ====================

  /// Daftar rentang waktu standar (Harian, Mingguan, Bulanan, hingga Tahunan).
  static List<String> get availablePeriods {
    final now = DateTime.now();
    return [
      'Semua Waktu',
      'Harian (Hari Ini)',
      'Mingguan (7 Hari Terakhir)',
      'Bulanan (Bulan Ini)',
      'Tahunan (Tahun ${now.year})',
      'Tahunan (Tahun 2024)',
    ];
  }

  /// Memfilter transaksi berdasarkan rentang waktu (`Harian`, `Mingguan`, `Bulanan`, `Tahunan`, atau `Rentang Kustom`).
  List<TransactionModel> filterTransactionsByPeriod(
    List<TransactionModel> source,
    String period,
  ) {
    final p = period.toLowerCase();
    if (p.isEmpty || p.contains('semua') || p.contains('tahunan')) {
      if (p.contains('2024')) {
        return source
            .where(
              (t) =>
                  t.dateGroup.contains('2024') ||
                  t.dateGroup.toLowerCase().contains('hari ini') ||
                  t.dateGroup.toLowerCase().contains('kemarin'),
            )
            .toList();
      }
      return source;
    }
    if (p.contains('harian') || p.contains('hari ini')) {
      return source
          .where(
            (t) =>
                t.dateGroup.toLowerCase().contains('hari ini') ||
                t.dateTime.toLowerCase().contains('hari ini'),
          )
          .toList();
    }
    if (p.contains('mingguan') || p.contains('7 hari')) {
      return source
          .where(
            (t) =>
                t.dateGroup.toLowerCase().contains('hari ini') ||
                t.dateGroup.toLowerCase().contains('kemarin') ||
                t.dateGroup.contains('24 Oktober') ||
                t.dateGroup.contains('23 Oktober') ||
                t.dateGroup.contains('20 Oktober'),
          )
          .toList();
    }
    return source;
  }

  /// Menghitung ringkasan pemasukan, pengeluaran, tabungan, dan skor kesehatan finansial (0-100)
  /// murni dari transaksi aktual pengguna (jika user baru belum ada transaksi, maka Rp 0).
  CashFlowSummaryModel calculateCashFlowSummary({
    String period = 'Semua Waktu',
    List<TransactionModel>? customTransactions,
  }) {
    final targetList = customTransactions ??
        filterTransactionsByPeriod(DummyData.transactions, period);

    var income = 0;
    var expense = 0;
    var saving = 0;

    for (final trx in targetList) {
      if (trx.type == TransactionType.income) {
        income += trx.amount.abs();
      } else if (trx.type == TransactionType.expense) {
        expense += trx.amount.abs();
      } else if (trx.type == TransactionType.saving) {
        saving += trx.amount.abs();
      }
    }

    if (targetList.isEmpty && income == 0 && expense == 0 && saving == 0) {
      return CashFlowSummaryModel(
        period: period,
        totalIncome: 0,
        totalExpense: 0,
        totalSaving: 0,
        financialHealthScore: 0,
        healthStatusLabel: 'Belum Ada Aktivitas',
        incomeGrowthLabel: 'Rp 0 (Belum ada pemasukan)',
        expenseRatioLabel: '0% dari pemasukan',
      );
    }

    final expenseRatio = income > 0
        ? ((expense / income) * 100).round().clamp(0, 100)
        : (expense > 0 ? 100 : 0);
    final savingRatio = income > 0
        ? (((DummyData.savingBalance + saving) / income) * 20)
            .round()
            .clamp(0, 30)
        : 0;

    // Skor Kesehatan Finansial (0-100)
    final healthScore = (100 - (expenseRatio * 0.5).round() + savingRatio)
        .clamp(45, 98);

    final statusLabel = switch (healthScore) {
      >= 80 => 'Sangat Sehat 🌟',
      >= 65 => 'Kondisi Sehat 👍',
      _ => 'Perlu Evaluasi ⚠️',
    };

    return CashFlowSummaryModel(
      period: period,
      totalIncome: income,
      totalExpense: expense,
      totalSaving: saving,
      financialHealthScore: healthScore,
      healthStatusLabel: statusLabel,
      incomeGrowthLabel: '${targetList.where((t) => t.isIncoming).length} transaksi masuk',
      expenseRatioLabel: '$expenseRatio% dari pemasukan',
    );
  }

  // ==================== FIRESTORE REST SYNC ====================

  /// Menyinkronkan data awal koleksi `saving_goals`, `loans`, dan `promos` ke Firestore agar langsung muncul di Firebase Console.
  Future<void> seedInitialWealthDataToFirestore() async {
    for (final goal in savingGoals) {
      await _syncSavingGoalToFirestore(goal);
    }
    for (final loan in activeLoans) {
      await _syncLoanToFirestore(loan);
    }
    for (final promo in promos) {
      await _syncPromoToFirestore(promo);
    }
  }

  /// Mengambil daftar target menabung milik `userId` dari koleksi `saving_goals` di Firestore.
  Future<List<SavingGoalModel>?> fetchSavingGoalsForUser(String userId) async {
    if (!FirebaseFirestoreConfig.isConfigured) return null;

    try {
      final url = Uri.parse('${FirebaseFirestoreConfig.baseUrl}/saving_goals');
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = (decoded['documents'] as List<dynamic>?) ?? [];
        final userGoals = <SavingGoalModel>[];
        for (final doc in docs) {
          final docMap = doc as Map<String, dynamic>;
          final fields = docMap['fields'] as Map<String, dynamic>?;
          if (fields == null) continue;

          final parsedMap = _fromFirestoreFields(fields);
          if (parsedMap['userId']?.toString() == userId) {
            userGoals.add(SavingGoalModel.fromMap(parsedMap));
          }
        }
        return userGoals;
      }
    } catch (_) {}

    return null;
  }

  /// Mengambil daftar pinjaman milik `userId` dari koleksi `loans` di Firestore.
  Future<List<LoanModel>?> fetchLoansForUser(String userId) async {
    if (!FirebaseFirestoreConfig.isConfigured) return null;

    try {
      final url = Uri.parse('${FirebaseFirestoreConfig.baseUrl}/loans');
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = (decoded['documents'] as List<dynamic>?) ?? [];
        final userLoans = <LoanModel>[];
        for (final doc in docs) {
          final docMap = doc as Map<String, dynamic>;
          final fields = docMap['fields'] as Map<String, dynamic>?;
          if (fields == null) continue;

          final parsedMap = _fromFirestoreFields(fields);
          if (parsedMap['userId']?.toString() == userId) {
            userLoans.add(LoanModel.fromMap(parsedMap));
          }
        }
        return userLoans;
      }
    } catch (_) {}

    return null;
  }

  Future<void> _syncSavingGoalToFirestore(SavingGoalModel goal) async {
    if (!FirebaseFirestoreConfig.isConfigured) return;

    try {
      final url = Uri.parse(
        '${FirebaseFirestoreConfig.baseUrl}/saving_goals/${goal.id}',
      );
      await http
          .patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fields': _toFirestoreFields(goal.toMap()),
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  Future<void> _syncLoanToFirestore(LoanModel loan) async {
    if (!FirebaseFirestoreConfig.isConfigured) return;

    try {
      final url = Uri.parse(
        '${FirebaseFirestoreConfig.baseUrl}/loans/${loan.id}',
      );
      await http
          .patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fields': _toFirestoreFields(loan.toMap()),
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  Future<void> _syncPromoToFirestore(PromoModel promo) async {
    if (!FirebaseFirestoreConfig.isConfigured) return;

    try {
      final url = Uri.parse(
        '${FirebaseFirestoreConfig.baseUrl}/promos/${promo.id}',
      );
      await http
          .patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fields': _toFirestoreFields(promo.toMap()),
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null) return;
      if (value is int) {
        result[key] = {'integerValue': value.toString()};
      } else if (value is double) {
        result[key] = {'doubleValue': value};
      } else if (value is bool) {
        result[key] = {'booleanValue': value};
      } else {
        result[key] = {'stringValue': value.toString()};
      }
    });
    return result;
  }

  Map<String, dynamic> _fromFirestoreFields(Map<String, dynamic> fields) {
    final result = <String, dynamic>{};
    fields.forEach((key, value) {
      final fieldMap = value as Map<String, dynamic>;
      if (fieldMap.containsKey('integerValue')) {
        result[key] = int.tryParse(fieldMap['integerValue'].toString()) ?? 0;
      } else if (fieldMap.containsKey('doubleValue')) {
        result[key] = (fieldMap['doubleValue'] as num).toDouble();
      } else if (fieldMap.containsKey('booleanValue')) {
        result[key] = fieldMap['booleanValue'] as bool;
      } else if (fieldMap.containsKey('stringValue')) {
        result[key] = fieldMap['stringValue'].toString();
      }
    });
    return result;
  }
}
