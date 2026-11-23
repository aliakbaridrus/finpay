import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/qris_model.dart';
import '../../../data/services/account_service.dart';
import '../../../data/services/midtrans_service.dart';
import '../../../data/services/qris_service.dart';
import '../../../data/services/transaction_service.dart';

/// Hasil transaksi dari jendela Midtrans Snap Simulator (sebagai jembatan pembayaran).
class MidtransSnapBridgeResult {
  const MidtransSnapBridgeResult({
    required this.order,
    required this.paymentMethod,
  });

  final MidtransOrderResult order;
  final String paymentMethod;
}

/// Menampilkan dialog **Midtrans Snap Payment Simulator** (3 layar interaktif:
/// Metode Pembayaran, Kartu Kredit/Debit, GoPay/QRIS, & Transfer Bank VA)
/// sebagai jembatan pembayaran Transfer & Top Up FinPay.
Future<MidtransSnapBridgeResult?> showMidtransSnapSimulator(
  BuildContext context, {
  required String merchantTitle,
  required int amount,
  String? recipientLabel,
  String? initialMethod,
}) {
  return showDialog<MidtransSnapBridgeResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _MidtransSnapModal(
          merchantTitle: merchantTitle,
          amount: amount,
          recipientLabel: recipientLabel,
          initialMethod: initialMethod,
        ),
      ),
    ),
  );
}

enum _SnapStep { methods, creditCard, gopayQris, bankTransfer }

class _MidtransSnapModal extends StatefulWidget {
  const _MidtransSnapModal({
    required this.merchantTitle,
    required this.amount,
    this.recipientLabel,
    this.initialMethod,
  });

  final String merchantTitle;
  final int amount;
  final String? recipientLabel;
  final String? initialMethod;

  @override
  State<_MidtransSnapModal> createState() => _MidtransSnapModalState();
}

class _MidtransSnapModalState extends State<_MidtransSnapModal> {
  static const Color _snapNavy = Color(0xFF0A2652);
  static const Color _snapButtonDark = Color(0xFF333A48);
  static const Color _snapBlue = Color(0xFF1D4ED8);

  late _SnapStep _step;
  late String _orderId;
  bool _showOrderDetails = false;
  bool _showHowToPay = false;
  bool _saveCard = true;
  bool _isSettling = false;
  String _selectedBank = 'BCA';
  int _remainingSeconds = 59 * 60 + 32;
  Timer? _countdownTimer;

  final TextEditingController _cardNumberController =
      TextEditingController(text: '4811-1111-1111-1114');
  final TextEditingController _cardExpiryController =
      TextEditingController(text: '12/28');
  final TextEditingController _cardCvvController =
      TextEditingController(text: '123');

  @override
  void initState() {
    super.initState();
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    _orderId = 'FPX-${ts.substring(ts.length - 8)}';

    final lower = (widget.initialMethod ?? '').toLowerCase();
    if (lower.contains('qris') || lower.contains('gopay')) {
      _step = _SnapStep.gopayQris;
    } else if (lower.contains('kartu') || lower.contains('card')) {
      _step = _SnapStep.creditCard;
    } else if (lower.contains('bank') || lower.contains('va')) {
      _step = _SnapStep.bankTransfer;
    } else {
      _step = _SnapStep.methods;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  String get _countdownText {
    final h = (_remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _selectedVaNumber {
    final cleanPhone = AccountService.instance.currentUser.phoneNumber
        .replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = cleanPhone.isNotEmpty ? cleanPhone : '081234567890';
    return switch (_selectedBank) {
      'BCA' => '88012 $suffix',
      'Mandiri' => '88013 $suffix',
      'BNI' => '88015 $suffix',
      'BRI' => '88014 $suffix',
      _ => '88016 $suffix',
    };
  }

  QrisPayload get _bridgeQrisPayload {
    return QrisPayload(
      merchantName: widget.merchantTitle,
      merchantCity: 'Jakarta',
      nmid: QrisService.instance.myNmid,
      merchantCategoryCode: '6012',
      amount: widget.amount,
      referenceLabel: _orderId,
      terminalLabel: 'MIDTRANS',
    );
  }

  Future<void> _completePayment(String methodLabel) async {
    if (_isSettling) return;
    setState(() => _isSettling = true);

    final activeUser = AccountService.instance.currentUser;
    final order = await MidtransService.instance.createSnapTransaction(
      userId: FirebaseFirestoreConfig.defaultUserId,
      customerName: activeUser.fullName,
      customerPhone: activeUser.phoneNumber,
      amount: widget.amount,
      paymentMethod: methodLabel,
    );

    if (!mounted) return;
    Navigator.pop(
      context,
      MidtransSnapBridgeResult(order: order, paymentMethod: methodLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 16,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopHeaderWithTotalCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: switch (_step) {
                _SnapStep.methods => _buildMethodsStep(),
                _SnapStep.creditCard => _buildCreditCardStep(),
                _SnapStep.gopayQris => _buildGopayQrisStep(),
                _SnapStep.bankTransfer => _buildBankTransferStep(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderWithTotalCard() {
    final timerPrefix =
        _step == _SnapStep.methods ? 'Pilih dalam' : 'Bayar dalam';

    return Stack(
      children: [
        Container(
          height: 112,
          color: _snapNavy,
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  'FP',
                  style: AppTextStyles.label.copyWith(
                    color: _snapNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.merchantTitle,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _isSettling ? null : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Tutup',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 66, 16, 4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                        children: [
                          TextSpan(text: '$timerPrefix '),
                          TextSpan(
                            text: _countdownText,
                            style: const TextStyle(
                              color: _snapBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () =>
                      setState(() => _showOrderDetails = !_showOrderDetails),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.rupiah(widget.amount),
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Icon(
                        _showOrderDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ID #$_orderId',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                if (_showOrderDetails) ...[
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  if (widget.recipientLabel != null)
                    _DetailRow(
                      label: 'Tujuan',
                      value: widget.recipientLabel!,
                    ),
                  const _DetailRow(
                    label: 'Jembatan Gateway',
                    value: 'Midtrans Sandbox Snap',
                  ),
                  const _DetailRow(
                    label: 'Biaya Admin',
                    value: 'Gratis (Rp 0)',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode pembayaran',
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _MethodOptionTile(
          title: 'Transfer bank',
          badges: const [
            _BrandChip('BCA', Color(0xFF00529C)),
            _BrandChip('mandiri', Color(0xFF003D79)),
            _BrandChip('BNI', Color(0xFFF15A23)),
            _BrandChip('BRI', Color(0xFF00529C)),
            _BrandChip('Permata', Color(0xFF15803D)),
          ],
          onTap: () => setState(() => _step = _SnapStep.bankTransfer),
        ),
        const Divider(height: 24, color: Color(0xFFE2E8F0)),
        _MethodOptionTile(
          title: 'Kartu kredit/debit',
          badges: const [
            _BrandChip('VISA', Color(0xFF1A1F71)),
            _BrandChip('MC', Color(0xFFEB001B)),
            _BrandChip('JCB', Color(0xFF0E4C96)),
            _BrandChip('AMEX', Color(0xFF006FCF)),
          ],
          onTap: () => setState(() => _step = _SnapStep.creditCard),
        ),
        const Divider(height: 24, color: Color(0xFFE2E8F0)),
        _MethodOptionTile(
          title: 'GoPay/QRIS',
          badges: const [
            _BrandChip('GoPay', Color(0xFF00AED6)),
            _BrandChip('QRIS', Color(0xFF0F172A)),
          ],
          onTap: () => setState(() => _step = _SnapStep.gopayQris),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Secure payments by Midtrans Sandbox',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _step = _SnapStep.methods),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                'Kartu kredit/debit',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nomor kartu',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const Row(
              children: [
                _BrandChip('VISA', Color(0xFF1A1F71)),
                SizedBox(width: 4),
                _BrandChip('MC', Color(0xFFEB001B)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0000-0000-0000-0000',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masa berlaku',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardExpiryController,
                    decoration: InputDecoration(
                      hintText: 'MM/YY',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CVV',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardCvvController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '•••',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _saveCard,
                activeColor: _snapNavy,
                onChanged: (v) => setState(() => _saveCard = v ?? true),
              ),
            ),
            const SizedBox(width: 8),
            Text('Simpan kartu ini', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Secure payments by Midtrans',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSettling
                ? null
                : () => _completePayment('Kartu Kredit/Debit Midtrans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _snapButtonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isSettling ? 'Memproses Midtrans...' : 'Bayar sekarang',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGopayQrisStep() {
    final qrisPayload = _bridgeQrisPayload;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => setState(() => _step = _SnapStep.methods),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'GoPay',
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const _BrandChip('gopay', Color(0xFF00AED6)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'QRIS',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: QrImageView(
              data: qrisPayload.encode(),
              size: 168,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'NMID: ${qrisPayload.nmid}',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => _showHowToPay = !_showHowToPay),
          child: Row(
            children: [
              const Icon(Icons.help_rounded, color: _snapBlue, size: 16),
              const SizedBox(width: 6),
              Text(
                'Cara bayar',
                style: AppTextStyles.label.copyWith(
                  color: _snapBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showHowToPay
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.unfold_more_rounded,
                color: _snapBlue,
                size: 16,
              ),
            ],
          ),
        ),
        if (_showHowToPay) ...[
          const SizedBox(height: 6),
          Text(
            '1. Pindai kode QRIS di atas melalui GoPay, FinPay, atau m-Banking.\n'
            '2. Pastikan nominal ${CurrencyFormatter.rupiah(widget.amount)} sudah sesuai.\n'
            '3. Klik "Saya sudah bayar" untuk menyelesaikan jembatan Midtrans Sandbox.',
            style: AppTextStyles.caption.copyWith(height: 1.5),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isSettling ? null : () => _completePayment('GoPay/QRIS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _snapButtonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isSettling ? 'Memverifikasi Midtrans...' : 'Saya sudah bayar',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferStep() {
    const banks = ['BCA', 'Mandiri', 'BNI', 'BRI', 'Permata'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _step = _SnapStep.methods),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                'Transfer bank',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final bank in banks)
              ChoiceChip(
                label: Text(bank),
                selected: _selectedBank == bank,
                selectedColor: _snapNavy,
                labelStyle: TextStyle(
                  color: _selectedBank == bank
                      ? Colors.white
                      : const Color(0xFF334155),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (_) => setState(() => _selectedBank = bank),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Virtual Account $_selectedBank',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedVaNumber,
                      style: AppTextStyles.h3.copyWith(
                        color: _snapNavy,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _selectedVaNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No. VA $_selectedBank disalin!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Salin',
                  style: TextStyle(
                    color: _snapBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSettling
                ? null
                : () => _completePayment('$_selectedBank Virtual Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _snapButtonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isSettling ? 'Memverifikasi Midtrans...' : 'Saya sudah bayar',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodOptionTile extends StatelessWidget {
  const _MethodOptionTile({
    required this.title,
    required this.badges,
    required this.onTap,
  });

  final String title;
  final List<Widget> badges;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: badges,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
