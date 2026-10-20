import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../widgets/sub_page_scaffold.dart';

class _Message {
  const _Message(this.text, {required this.fromUser, required this.time});

  final String text;
  final bool fromUser;
  final String time;
}

/// Hubungi CS: UI chat dengan balasan otomatis (dummy).
/// Nanti bisa diganti koneksi ke layanan chat sungguhan.
class ContactCsPage extends StatefulWidget {
  const ContactCsPage({super.key});

  @override
  State<ContactCsPage> createState() => _ContactCsPageState();
}

class _ContactCsPageState extends State<ContactCsPage> {
  static const List<String> _quickReplies = [
    'Transfer gagal',
    'Lupa PIN',
    'Naikkan limit',
    'Kartu hilang',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Message> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Message(
      'Halo! Aku Fina, asisten virtual FinPay. Ada yang bisa kubantu hari ini?',
      fromUser: false,
      time: _now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _now() {
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Balasan sederhana berdasarkan kata kunci.
  String _replyFor(String text) {
    final q = text.toLowerCase();
    if (q.contains('transfer')) {
      return 'Untuk transfer yang gagal, saldo biasanya dikembalikan otomatis '
          'maksimal 1x24 jam. Boleh kirim nominal dan waktu transaksinya?';
    }
    if (q.contains('pin')) {
      return 'Kamu bisa reset PIN lewat Akun > Keamanan > Ubah PIN, atau '
          'ketuk Lupa PIN saat login untuk verifikasi OTP.';
    }
    if (q.contains('limit')) {
      return 'Limit harian bisa diatur di Akun > Limit Transaksi. Untuk '
          'limit di atas Rp 50 juta, aku bantu teruskan ke tim verifikasi.';
    }
    if (q.contains('kartu') || q.contains('hilang')) {
      return 'Tenang ya. Segera bekukan kartu di Akun > Rekening & Kartu. '
          'Setelah itu aku bantu proses penggantian kartunya.';
    }
    return 'Terima kasih sudah menghubungi FinPay. Pesanmu sudah kuterima '
        'dan akan ditindaklanjuti agen CS kami.';
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;

    setState(() {
      _messages.add(_Message(text, fromUser: true, time: _now()));
      _typing = true;
    });
    _controller.clear();
    _scrollToEnd();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Message(_replyFor(text), fromUser: false, time: _now()));
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Hubungi CS',
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.page),
          child: Center(
            child: PillBadge(
              label: 'Online',
              leadingIcon: Icons.circle,
              backgroundColor: AppColors.successLight,
              foregroundColor: AppColors.success,
            ),
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return const _TypingBubble();
                return _Bubble(message: _messages[index]);
              },
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => ActionChip(
                label: Text(_quickReplies[i]),
                onPressed: () => _send(_quickReplies[i]),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                labelStyle:
                    AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _send,
              textInputAction: TextInputAction.send,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.pillAll,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _send(_controller.text),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final user = message.fromUser;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : AppColors.surface,
          boxShadow: user ? null : AppShadows.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(user ? AppRadius.lg : 4),
            bottomRight: Radius.circular(user ? 4 : AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.body.copyWith(
                color: user ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message.time,
              style: AppTextStyles.caption.copyWith(
                color: user
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.card,
        ),
        child: Text('Fina sedang mengetik...', style: AppTextStyles.caption),
      ),
    );
  }
}
