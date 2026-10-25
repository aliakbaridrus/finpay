import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../dummy/dummy_data.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'midtrans_service.dart';
import 'transaction_service.dart';

/// Service Backend Dompet & Pembayaran (Bagian Tugas Ali).
///
/// Mengelola:
/// 1. Koleksi `wallets` & `midtrans_orders` di Firebase Firestore
/// 2. Top Up Saldo via Midtrans Sandbox
/// 3. Transfer Sesama FinPay & Antar Bank
/// 4. Pembayaran QRIS & Pembuatan Kode Tarik Tunai ATM
class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final ValueNotifier<WalletModel> walletNotifier = ValueNotifier<WalletModel>(
    WalletModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      cashBalance: DummyData.cashBalance,
      savingBalance: DummyData.savingBalance,
      updatedAt: DateTime.now(),
    ),
  );

  /// Mengambil kondisi dompet pengguna saat ini.
  WalletModel get currentWallet => WalletModel(
        userId: FirebaseFirestoreConfig.defaultUserId,
        cashBalance: DummyData.cashBalance,
        savingBalance: DummyData.savingBalance,
        updatedAt: DateTime.now(),
      );

  /// Inisialisasi dokumen saldo awal untuk user baru (dapat dipanggil oleh AuthService milik Pidi).
  Future<void> initWallet(String userId, {int initialCash = 0}) async {
    final wallet = WalletModel(
      userId: userId,
      cashBalance: initialCash,
      savingBalance: 0,
      updatedAt: DateTime.now(),
    );
    await _syncWalletToFirestore(wallet);
  }

  /// Update saldo utama / saldo tabungan dan sinkronkan ke Firebase Firestore.
  Future<WalletModel> updateBalance({
    int? cashDelta,
    int? savingDelta,
  }) async {
    if (cashDelta != null) {
      DummyData.cashBalance += cashDelta;
      DummyData.totalBalance = DummyData.cashBalance + DummyData.savingBalance;
    }
    if (savingDelta != null) {
      DummyData.savingBalance += savingDelta;
      DummyData.totalBalance = DummyData.cashBalance + DummyData.savingBalance;
    }

    final updated = currentWallet;
    walletNotifier.value = updated;
    await _syncWalletToFirestore(updated);
    return updated;
  }

  /// Proses Top Up Saldo terintegrasi dengan Midtrans Sandbox + pencatatan Firestore.
  Future<MidtransOrderResult> topUpWithMidtrans({
    required int amount,
    required String paymentMethod,
    required String timeFormatted,
  }) async {
    // 1. Buat transaksi Snap di Midtrans Sandbox
    final order = await MidtransService.instance.createSnapTransaction(
      userId: FirebaseFirestoreConfig.defaultUserId,
      customerName: DummyData.userName,
      customerPhone: DummyData.phoneNumber,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    // 2. Simpan log order Midtrans ke koleksi `midtrans_orders` di Firestore
    await _saveMidtransOrderToFirestore(order);

    // 3. Cek status pembayaran Midtrans Sandbox
    final paymentStatus =
        await MidtransService.instance.checkPaymentStatus(order.orderId);

    if (paymentStatus == 'settlement' || paymentStatus == 'capture') {
      await updateBalance(cashDelta: amount);

      final trx = TransactionModel(
        userId: FirebaseFirestoreConfig.defaultUserId,
        title: 'Isi Saldo $paymentMethod',
        dateTime: 'Hari Ini, $timeFormatted',
        channel: paymentMethod,
        amount: amount,
        icon: Icons.add_circle_outline_rounded,
        type: TransactionType.income,
        referenceNumber: order.orderId,
        category: 'Isi Saldo',
        dateGroup: 'Hari Ini',
        note: 'Top Up Midtrans Sandbox (${order.snapToken})',
      );

      await TransactionService.instance.addTransaction(trx);
    }

    return order;
  }

  /// Proses Transfer Uang (Sesama FinPay / Rekening Bank).
  Future<TransactionModel> transferMoney({
    required String recipient,
    required int amount,
    required bool isBankTransfer,
    required String timeFormatted,
    String? note,
  }) async {
    if (amount <= 0) {
      throw Exception('Nominal transfer harus lebih dari Rp 0.');
    }
    if (amount > DummyData.cashBalance) {
      throw Exception('Saldo FinPay Cash kamu tidak mencukupi!');
    }

    await updateBalance(cashDelta: -amount);

    final referenceNumber =
        'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final trx = TransactionModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: 'Transfer ke $recipient',
      dateTime: 'Hari Ini, $timeFormatted',
      channel: isBankTransfer ? 'Transfer Bank' : 'Antar FinPay',
      amount: -amount,
      icon: Icons.person_outline_rounded,
      type: TransactionType.expense,
      referenceNumber: referenceNumber,
      category: 'Transfer',
      dateGroup: 'Hari Ini',
      note: (note == null || note.trim().isEmpty) ? 'Transfer dana' : note,
    );

    await TransactionService.instance.addTransaction(trx);
    return trx;
  }

  /// Proses Pembayaran Scan QRIS Merchant.
  Future<TransactionModel> payWithQris({
    required String merchantName,
    required int amount,
    required String timeFormatted,
  }) async {
    if (amount > DummyData.cashBalance) {
      throw Exception('Saldo FinPay Cash kamu tidak mencukupi!');
    }

    await updateBalance(cashDelta: -amount);

    final referenceNumber =
        'FPX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final trx = TransactionModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: 'Belanja QRIS $merchantName',
      dateTime: 'Hari Ini, $timeFormatted',
      channel: 'QRIS Pay',
      amount: -amount,
      icon: Icons.qr_code_scanner_rounded,
      type: TransactionType.expense,
      referenceNumber: referenceNumber,
      category: 'Pembayaran Merchant',
      dateGroup: 'Hari Ini',
      note: 'Pembayaran QRIS di $merchantName',
    );

    await TransactionService.instance.addTransaction(trx);
    return trx;
  }

  /// Membuat Kode Tarik Tunai ATM / Minimarket & memotong saldo utama.
  Future<Map<String, String>> createCashoutCode({
    required int amount,
    required String channelName,
    required String timeFormatted,
  }) async {
    if (amount > DummyData.cashBalance) {
      throw Exception('Saldo FinPay Cash kamu tidak mencukupi!');
    }

    await updateBalance(cashDelta: -amount);

    final millis = DateTime.now().millisecondsSinceEpoch.toString();
    final referenceNumber = 'FPX-${millis.substring(5)}';
    final tokenCode =
        '${millis.substring(millis.length - 4)}-${millis.substring(millis.length - 8, millis.length - 4)}-4819';

    final trx = TransactionModel(
      userId: FirebaseFirestoreConfig.defaultUserId,
      title: 'Tarik Tunai $channelName',
      dateTime: 'Hari Ini, $timeFormatted',
      channel: 'Tarik Tunai',
      amount: -amount,
      icon: Icons.payments_outlined,
      type: TransactionType.expense,
      referenceNumber: referenceNumber,
      category: 'Tarik Tunai',
      dateGroup: 'Hari Ini',
      note: 'Kode Penarikan: $tokenCode',
    );

    await TransactionService.instance.addTransaction(trx);
    return {
      'tokenCode': tokenCode,
      'referenceNumber': referenceNumber,
    };
  }

  Future<void> _syncWalletToFirestore(WalletModel wallet) async {
    if (!FirebaseFirestoreConfig.isConfigured) return;

    try {
      final url = Uri.parse(
        '${FirebaseFirestoreConfig.baseUrl}/wallets/${wallet.userId}',
      );
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 6);
      final request = await client.patchUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final payload = {
        'fields': {
          'userId': {'stringValue': wallet.userId},
          'cashBalance': {'integerValue': wallet.cashBalance.toString()},
          'savingBalance': {'integerValue': wallet.savingBalance.toString()},
          'totalWealth': {'integerValue': wallet.totalWealth.toString()},
          'updatedAt': {
            'stringValue':
                (wallet.updatedAt ?? DateTime.now()).toIso8601String(),
          },
        },
      };

      request.write(jsonEncode(payload));
      final response = await request.close();
      await response.drain<void>();
      client.close();
    } catch (_) {
      // Tetap aman secara lokal jika belum ada koneksi internet.
    }
  }

  Future<void> _saveMidtransOrderToFirestore(MidtransOrderResult order) async {
    if (!FirebaseFirestoreConfig.isConfigured) return;

    try {
      final url = Uri.parse(
        '${FirebaseFirestoreConfig.baseUrl}/midtrans_orders?documentId=${order.orderId}',
      );
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 6);
      final request = await client.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final payload = {
        'fields': {
          'orderId': {'stringValue': order.orderId},
          'userId': {'stringValue': order.userId},
          'amount': {'integerValue': order.amount.toString()},
          'paymentType': {'stringValue': order.paymentMethod},
          'snapToken': {'stringValue': order.snapToken},
          'redirectUrl': {'stringValue': order.redirectUrl},
          'vaNumber': {'stringValue': order.vaNumber},
          'status': {'stringValue': order.status},
          'createdAt': {'stringValue': order.createdAt.toIso8601String()},
        },
      };

      request.write(jsonEncode(payload));
      final response = await request.close();
      await response.drain<void>();
      client.close();
    } catch (_) {}
  }
}
