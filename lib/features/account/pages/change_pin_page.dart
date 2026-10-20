import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/sub_page_scaffold.dart';

/// Ubah PIN dalam 3 tahap: PIN lama -> PIN baru -> konfirmasi.
/// Menutup halaman dengan hasil `true` kalau PIN berhasil diubah.
class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  // DEMO: PIN lama di-hardcode. Nanti diganti verifikasi ke backend.
  static const String _currentPin = '123456';
  static const int _length = 6;

  static const List<String> _titles = [
    'Masukkan PIN lama',
    'Buat PIN baru',
    'Konfirmasi PIN baru',
  ];
  static const List<String> _subtitles = [
    'Untuk keamanan, masukkan PIN FinPay kamu saat ini.',
    'Gunakan 6 digit angka yang mudah kamu ingat.',
    'Masukkan ulang PIN baru untuk memastikan tidak salah ketik.',
  ];

  int _stage = 0;
  String _input = '';
  String _newPin = '';
  String? _error;

  void _onDigit(String digit) {
    if (_input.length >= _length) return;
    setState(() {
      _input += digit;
      _error = null;
    });
    if (_input.length == _length) {
      // Jeda singkat supaya titik ke-6 sempat terlihat terisi.
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) _submit();
      });
    }
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  /// PIN seperti 111111 atau 123456 gampang ditebak.
  bool _tooEasy(String pin) =>
      pin.split('').toSet().length == 1 ||
      '0123456789'.contains(pin) ||
      '9876543210'.contains(pin);

  void _fail(String message) {
    setState(() {
      _input = '';
      _error = message;
    });
  }

  void _goTo(int stage) {
    setState(() {
      _stage = stage;
      _input = '';
      _error = null;
    });
  }

  void _submit() {
    switch (_stage) {
      case 0:
        if (_input != _currentPin) {
          _fail('PIN lama salah, coba lagi.');
        } else {
          _goTo(1);
        }
      case 1:
        if (_input == _currentPin) {
          _fail('PIN baru tidak boleh sama dengan PIN lama.');
        } else if (_tooEasy(_input)) {
          _fail('PIN terlalu mudah ditebak, coba kombinasi lain.');
        } else {
          _newPin = _input;
          _goTo(2);
        }
      default:
        if (_input != _newPin) {
          setState(() {
            _stage = 1;
            _input = '';
            _newPin = '';
            _error = 'PIN tidak cocok. Ulangi dari PIN baru.';
          });
        } else {
          Navigator.pop(context, true);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Ubah PIN',
      children: [
        _buildStageBar(),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          _titles[_stage],
          textAlign: TextAlign.center,
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _subtitles[_stage],
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildDots(),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 32,
          child: Center(
            child: Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildKeypad(),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            'Mode demo: PIN lama adalah 123456',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }

  Widget _buildStageBar() {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _stage ? AppColors.primary : AppColors.border,
                borderRadius: AppRadius.pillAll,
              ),
            ),
          ),
          if (i != 2) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _input.length ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: i < _input.length ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                      ),
                      child: _PinKey(
                        label: key,
                        onTap: key == '<' ? _onBackspace : () => _onDigit(key),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Slot kosong (kiri bawah) hanya penyeimbang layout.
    if (label.isEmpty) return const SizedBox(height: 56);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          height: 56,
          child: Center(
            child: label == '<'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textSecondary,
                  )
                : Text(label, style: AppTextStyles.h1),
          ),
        ),
      ),
    );
  }
}
