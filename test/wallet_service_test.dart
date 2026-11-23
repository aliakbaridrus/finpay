import 'package:finpay/data/dummy/dummy_data.dart';
import 'package:finpay/data/models/transaction_model.dart';
import 'package:finpay/data/services/auth_service.dart';
import 'package:finpay/data/services/transaction_service.dart';
import 'package:finpay/data/services/wallet_service.dart';
import 'package:finpay/shared/dialogs/widgets/midtrans_snap_simulator_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int initialCash;
  late int initialSaving;

  setUp(() {
    // Nonaktifkan panggilan jaringan Firestore saat unit test
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

  group('WalletService action sheets backend', () {
    test('depositToSaving memindahkan saldo cash ke tabungan dan mencatat transaksi', () async {
      final trx = await WalletService.instance.depositToSaving(
        amount: 250000,
        goalTitle: 'Liburan ke Jepang',
        timeFormatted: '19:30',
      );

      expect(DummyData.cashBalance, initialCash - 250000);
      expect(DummyData.savingBalance, initialSaving + 250000);
      expect(trx.type, TransactionType.saving);
      expect(trx.referenceNumber, startsWith('FPX-SV'));
    });

    test('disburseLoan mencairkan dana ke saldo cash dan menghitung cicilan', () async {
      final res = await WalletService.instance.disburseLoan(
        amount: 6000000,
        tenorMonths: 6,
        timeFormatted: '19:35',
      );

      expect(DummyData.cashBalance, initialCash + 6000000);
      expect(res.transaction.type, TransactionType.income);
      expect(res.transaction.referenceNumber, startsWith('FPX-LN'));
      expect(res.monthlyInstallment, greaterThan(1000000));
    });

    test('transferMoney memotong saldo cash dan mencatat referensi FPX', () async {
      final trx = await WalletService.instance.transferMoney(
        recipient: '0812-9988-7766 (Budi)',
        amount: 150000,
        isBankTransfer: false,
        timeFormatted: '19:40',
        note: 'Patungan',
      );

      expect(DummyData.cashBalance, initialCash - 150000);
      expect(trx.type, TransactionType.expense);
      expect(trx.amount, -150000);
    });

    test('createCashoutCode memotong saldo cash dan mengembalikan tokenCode', () async {
      final res = await WalletService.instance.createCashoutCode(
        amount: 200000,
        channelName: 'Indomaret',
        timeFormatted: '19:45',
      );

      expect(DummyData.cashBalance, initialCash - 200000);
      expect(res['tokenCode'], isNotNull);
      expect(res['referenceNumber'], startsWith('FPX-'));
    });

    test(
      'transferMoney via Midtrans bridge mengkreditkan saldo & riwayat akun Ali tanpa saldo fiktif',
      () async {
        // Pastikan sesi awal sebagai Reza dengan saldo terkontrol
        await AuthService.instance.loginWithIdentifier(
          identifier: 'reza.pratama@email.com',
          secret: '123456',
        );
        final rezaStart = DummyData.cashBalance;

        final trx = await WalletService.instance.transferMoney(
          recipient: '087841819117 (Ali Akbar)',
          amount: 125000,
          isBankTransfer: false,
          timeFormatted: '20:15',
          note: 'Bayar makan siang',
          midtransOrderId: 'MID-TEST-99881',
          midtransMethod: 'GoPay/QRIS',
        );

        expect(DummyData.cashBalance, rezaStart - 125000);
        expect(trx.referenceNumber, 'MID-TEST-99881');
        expect(trx.channel, 'Midtrans GoPay/QRIS');

        // Login sebagai Ali Akbar -> saldo & riwayat terima transfer harus sesuai (+125000, bukan Rp 5.450.000)
        await AuthService.instance.loginWithIdentifier(
          identifier: '81388997766',
          secret: '123456',
        );
        expect(DummyData.cashBalance, greaterThanOrEqualTo(125000));
        expect(DummyData.cashBalance, lessThan(5000000));
        final aliIncoming =
            TransactionService.instance.transactionsNotifier.value.where(
          (t) => t.referenceNumber == 'MID-TEST-99881-IN',
        );
        expect(aliIncoming, isNotEmpty);
        expect(aliIncoming.first.amount, 125000);
        expect(aliIncoming.first.title, contains('Terima Transfer'));

        // Kembalikan sesi ke Reza
        await AuthService.instance.loginWithIdentifier(
          identifier: 'reza.pratama@email.com',
          secret: '123456',
        );
      },
    );
  });

  group('Midtrans Snap 3-screen simulator dialog', () {
    testWidgets(
      'menampilkan 3 layar (Metode pembayaran, Kartu kredit/debit, GoPay/QRIS) dan mengembalikan MidtransSnapBridgeResult',
      (tester) async {
        MidtransSnapBridgeResult? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showMidtransSnapSimulator(
                      context,
                      merchantTitle: 'FinPay Transfer',
                      amount: 350000,
                      recipientLabel: 'Ali Akbar (087841819117)',
                    );
                  },
                  child: const Text('Buka Snap'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Buka Snap'));
        await tester.pumpAndSettle();

        // Layar 1: Metode pembayaran
        expect(find.text('Metode pembayaran'), findsOneWidget);
        expect(find.text('Transfer bank'), findsOneWidget);
        expect(find.text('Kartu kredit/debit'), findsOneWidget);
        expect(find.text('GoPay/QRIS'), findsOneWidget);

        // Buka Layar 2: Kartu kredit/debit lalu kembali
        await tester.tap(find.text('Kartu kredit/debit'));
        await tester.pumpAndSettle();
        expect(find.text('Bayar sekarang'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();

        // Buka Layar 3: GoPay/QRIS dan konfirmasi 'Saya sudah bayar'
        await tester.tap(find.text('GoPay/QRIS'));
        await tester.pumpAndSettle();
        expect(find.text('Saya sudah bayar'), findsOneWidget);

        await tester.tap(find.text('Saya sudah bayar'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.paymentMethod, 'GoPay/QRIS');
        expect(result!.order.amount, 350000);
      },
    );
  });
}
