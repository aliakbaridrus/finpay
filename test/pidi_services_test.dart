import 'dart:convert';

import 'package:finpay/core/utils/pdf_statement_generator.dart';
import 'package:finpay/data/dummy/dummy_data.dart';
import 'package:finpay/data/services/account_service.dart';
import 'package:finpay/data/services/auth_service.dart';
import 'package:finpay/data/services/transaction_service.dart';
import 'package:finpay/data/services/wealth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int initialCash;
  late int initialSaving;

  setUp(() {
    FirebaseFirestoreConfig.projectId = '';
    initialCash = DummyData.cashBalance;
    initialSaving = DummyData.savingBalance;
  });

  tearDown(() {
    DummyData.cashBalance = initialCash;
    DummyData.savingBalance = initialSaving;
    DummyData.totalBalance = initialCash + initialSaving;
    FirebaseFirestoreConfig.projectId = 'finpay-app-4026a';
  });

  group('Tugas Pidi - AuthService, AccountService, & WealthService', () {
    test('AuthService register akun baru wajib saldo 0 dan login user lama memulihkan saldo terakhir', () async {
      // 1. Register user baru -> saldo wajib Rp 0 & data diri sesuai input
      final newUser = await AuthService.instance.register(
        fullName: 'Andi Wijaya',
        nik: '3174123456780002',
        birthDate: '10 Mei 2002',
        address: 'Jl. Diponegoro No. 10, Bandung',
        email: 'andi.wijaya@email.com',
        phoneNumber: '0813-9999-8888',
        password: 'password123',
        pin: '654321',
      );

      expect(newUser.fullName, 'Andi Wijaya');
      expect(newUser.nik, '3174123456780002');
      expect(newUser.birthDate, '10 Mei 2002');
      expect(newUser.address, 'Jl. Diponegoro No. 10, Bandung');
      expect(DummyData.cashBalance, 0);
      expect(DummyData.savingBalance, 0);
      expect(DummyData.transactions, isEmpty);

      // Cash Flow user baru wajib Rp 0 (belum ada uang masuk atau keluar)
      final newUserSummary = WealthService.instance.calculateCashFlowSummary();
      expect(newUserSummary.totalIncome, 0);
      expect(newUserSummary.totalExpense, 0);
      expect(newUserSummary.totalSaving, 0);
      expect(newUserSummary.netSurplus, 0);

      // 2. Login kembali sebagai user lama (Reza Pratama) -> saldo & riwayat Reza pulih kembali
      final oldUser = await AuthService.instance.login(
        email: 'reza.pratama@email.com',
        password: 'password123',
      );

      expect(oldUser.fullName, 'Reza Pratama');
      expect(DummyData.cashBalance, 12350000);
      expect(DummyData.savingBalance, 2500000);
      expect(DummyData.transactions, isNotEmpty);
    });

    test('AuthService login, changePin, dan logout bekerja dengan benar', () async {
      final user = await AuthService.instance.login(
        email: 'reza.pratama@email.com',
        password: 'password123',
      );

      expect(AuthService.instance.isLoggedIn, isTrue);
      expect(user.fullName, 'Reza Pratama');
      expect(AuthService.instance.validatePin('123456'), isTrue);

      await AuthService.instance.changePin(
        oldPin: '123456',
        newPin: '852963',
      );
      expect(AuthService.instance.validatePin('852963'), isTrue);

      // Kembalikan PIN default untuk tes lain
      await AuthService.instance.changePin(
        oldPin: '852963',
        newPin: '658241',
      );

      await AuthService.instance.logout();
      expect(AuthService.instance.isLoggedIn, isFalse);
    });

    test('AccountService updateProfile, updateDailyLimit, dan tambah rekening bank', () async {
      final updated = await AccountService.instance.updateProfile(
        address: 'Jl. Sudirman Kav. 52, Jakarta',
      );
      expect(updated.address, 'Jl. Sudirman Kav. 52, Jakarta');

      final limitUpdated =
          await AccountService.instance.updateDailyLimit(35000000);
      expect(limitUpdated.dailyLimit, 35000000);

      final initialCount = AccountService.instance.linkedAccounts.length;
      final addedAcc = await AccountService.instance.addLinkedAccount(
        bankName: 'BNI',
        accountNumber: '098765432100',
      );
      expect(AccountService.instance.linkedAccounts.length, initialCount + 1);
      expect(addedAcc.last4, '2100');

      await AccountService.instance.removeLinkedAccount(addedAcc.id);
      expect(AccountService.instance.linkedAccounts.length, initialCount);
    });

    test('WealthService createSavingGoal, depositToGoal, dan withdrawFromGoal', () async {
      final goal = await WealthService.instance.createSavingGoal(
        title: 'Beli Kamera Mirrorless',
        targetAmount: 6000000,
      );

      expect(goal.currentAmount, 0);

      await WealthService.instance.depositToGoal(
        goalId: goal.id,
        amount: 500000,
        timeFormatted: '10:00',
      );

      expect(DummyData.cashBalance, initialCash - 500000);
      expect(DummyData.savingBalance, initialSaving + 500000);

      await WealthService.instance.withdrawFromGoal(
        goalId: goal.id,
        amount: 200000,
        timeFormatted: '10:15',
      );

      expect(DummyData.cashBalance, initialCash - 300000);
      expect(DummyData.savingBalance, initialSaving + 300000);
    });

    test('WealthService applyLoan, payLoanInstallment, claimPromo, & calculateCashFlowSummary', () async {
      final loanRes = await WealthService.instance.applyLoan(
        amount: 3000000,
        tenorMonths: 3,
        timeFormatted: '11:00',
      );

      expect(DummyData.cashBalance, initialCash + 3000000);
      expect(loanRes.loan.paidMonths, 0);

      final payRes = await WealthService.instance.payLoanInstallment(
        loanId: loanRes.loan.id,
        timeFormatted: '11:05',
      );
      expect(payRes.loan.paidMonths, 1);

      final promo = await WealthService.instance.claimPromo('promo_qris_50');
      expect(promo.isClaimed, isTrue);

      final summary = WealthService.instance.calculateCashFlowSummary();
      expect(summary.financialHealthScore, greaterThanOrEqualTo(45));
      expect(summary.netSurplus, summary.totalIncome - summary.totalExpense);

      // Generator e-Statement wajib menghasilkan dokumen cetak berformat %PDF-1.4 (.pdf)
      final pdfBytes = PdfStatementGenerator.generatePdfBytes(
        user: AccountService.instance.currentUser,
        summary: summary,
        transactions: DummyData.transactions,
        periodLabel: 'Semua Waktu',
        generatedDateLabel: '19 November 2026',
      );
      final pdfText = latin1.decode(pdfBytes);
      expect(pdfText, startsWith('%PDF-1.4'));
      expect(pdfText, contains('FINPAY DIGITAL WALLET - E-STATEMENT RESMI'));
      expect(pdfText, endsWith('%%EOF'));
    });
  });
}
