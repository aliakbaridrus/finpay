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

  SupportMessageModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    bool? isFromAdmin,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return SupportMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      isFromAdmin: isFromAdmin ?? this.isFromAdmin,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
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

  Map<String, dynamic> toFirestoreFields() {
    return {
      'id': {'stringValue': id},
      'userId': {'stringValue': userId},
      'userName': {'stringValue': userName},
      'text': {'stringValue': text},
      'isFromAdmin': {'booleanValue': isFromAdmin},
      'timestamp': {'stringValue': timestamp.toIso8601String()},
      'isRead': {'booleanValue': isRead},
    };
  }

  factory SupportMessageModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return SupportMessageModel(
      id: docId ??
          (map['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
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

  factory SupportMessageModel.fromFirestoreFields(
    Map<String, dynamic> fields, {
    String? docId,
  }) {
    String readStr(String key, [String fallback = '']) {
      final raw = fields[key];
      if (raw is Map<String, dynamic> && raw['stringValue'] != null) {
        return raw['stringValue'].toString();
      }
      return fallback;
    }

    bool readBool(String key, {bool fallback = false}) {
      final raw = fields[key];
      if (raw is Map<String, dynamic> && raw['booleanValue'] is bool) {
        return raw['booleanValue'] as bool;
      }
      return fallback;
    }

    final parsedId = readStr('id', docId ?? '');
    return SupportMessageModel(
      id: parsedId.isNotEmpty
          ? parsedId
          : (docId ?? 'msg_${DateTime.now().millisecondsSinceEpoch}'),
      userId: readStr('userId', 'finpay_user_01'),
      userName: readStr('userName', 'Pengguna FinPay'),
      text: readStr('text'),
      isFromAdmin: readBool('isFromAdmin'),
      timestamp:
          DateTime.tryParse(readStr('timestamp')) ?? DateTime.now(),
      isRead: readBool('isRead'),
    );
  }
}
