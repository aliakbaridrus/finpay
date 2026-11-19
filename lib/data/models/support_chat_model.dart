/// Model data pesan bantuan Customer Support untuk komunikasi User ↔ Admin.
/// Disinkronkan dengan koleksi `support_chats` di Firebase Firestore.
class SupportMessageModel {
  const SupportMessageModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.isFromAdmin,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String text;
  final bool isFromAdmin;
  final DateTime timestamp;
  final bool isRead;

  String get timeFormatted {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'isFromAdmin': isFromAdmin,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory SupportMessageModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SupportMessageModel(
      id: docId ?? (map['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (map['userId'] as String?) ?? 'finpay_user_01',
      userName: (map['userName'] as String?) ?? 'Pengguna FinPay',
      text: (map['text'] as String?) ?? '',
      isFromAdmin: (map['isFromAdmin'] as bool?) ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: (map['isRead'] as bool?) ?? false,
    );
  }
}
