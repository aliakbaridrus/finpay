import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../dummy/dummy_data.dart';
import '../models/support_chat_model.dart';
import 'transaction_service.dart';

/// Service Komunikasi & Live Chat Customer Support (User ↔ Admin).
/// Mengelola pesan bantuan secara real-time dan menyinkronkannya ke koleksi `support_chats` di Firebase Firestore.
class SupportChatService {
  SupportChatService._() {
    _initDefaultMessages();
  }
  static final SupportChatService instance = SupportChatService._();

  final ValueNotifier<List<SupportMessageModel>> messagesNotifier =
      ValueNotifier<List<SupportMessageModel>>([]);

  void _initDefaultMessages() {
    final now = DateTime.now();
    messagesNotifier.value = [
      SupportMessageModel(
        id: 'msg_01',
        userId: 'finpay_user_01',
        userName: DummyData.userName,
        text: 'Halo! Saya mengalami kendala top up saldo via BCA Virtual Account belum masuk.',
        isFromAdmin: false,
        timestamp: now.subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
      SupportMessageModel(
        id: 'msg_02',
        userId: 'finpay_user_01',
        userName: 'Admin FinPay',
        text: 'Halo Kak Reza! Baik, boleh kami minta nomor referensi transaksi (FPX) dan bukti transfernya untuk kami verifikasi?',
        isFromAdmin: true,
        timestamp: now.subtract(const Duration(minutes: 20)),
        isRead: true,
      ),
      SupportMessageModel(
        id: 'msg_03',
        userId: 'finpay_user_01',
        userName: DummyData.userName,
        text: 'Nomor referensinya FPX-90821231 nominal Rp 500.000.',
        isFromAdmin: false,
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
      SupportMessageModel(
        id: 'msg_04',
        userId: 'finpay_user_01',
        userName: 'Admin FinPay',
        text: 'Terima kasih Kak. Transaksi sudah kami sinkronkan dan saldo kas sebesar Rp 500.000 sudah masuk ke dompet Kakak. Ada hal lain yang bisa kami bantu?',
        isFromAdmin: true,
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
    ];
  }

  /// Mengambil seluruh pesan untuk satu user tertentu.
  List<SupportMessageModel> getMessagesForUser(String userId) {
    return messagesNotifier.value
        .where((m) => m.userId == userId)
        .toList();
  }

  /// Mengirim pesan baru (bisa dari User HP atau Admin Web).
  Future<void> sendMessage({
    required String userId,
    required String userName,
    required String text,
    required bool isFromAdmin,
  }) async {
    final msg = SupportMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      text: text,
      isFromAdmin: isFromAdmin,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final current = List<SupportMessageModel>.from(messagesNotifier.value)..add(msg);
    messagesNotifier.value = current;

    // Sync ke Firebase Firestore menggunakan package:http (kompatibel Web Chrome, Android, & Desktop)
    if (FirebaseFirestoreConfig.isConfigured) {
      try {
        final url = Uri.parse(
          '${FirebaseFirestoreConfig.baseUrl}/support_chats/${msg.id}',
        );
        final payload = {
          'fields': msg.toFirestoreFields(),
        };

        await http
            .patch(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 6));
      } catch (_) {
        // Tetap aman menggunakan state lokal jika jaringan sedang offline.
      }
    }
  }

  /// Menandai semua pesan dari user tertentu sebagai sudah dibaca (read) oleh Admin.
  void markMessagesAsRead(String userId) {
    final updated = messagesNotifier.value.map((msg) {
      if (msg.userId == userId && !msg.isFromAdmin) {
        return SupportMessageModel(
          id: msg.id,
          userId: msg.userId,
          userName: msg.userName,
          text: msg.text,
          isFromAdmin: msg.isFromAdmin,
          timestamp: msg.timestamp,
          isRead: true,
        );
      }
      return msg;
    }).toList();

    messagesNotifier.value = updated;
  }
}
