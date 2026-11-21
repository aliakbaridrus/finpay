import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../auth/widgets/pin_pad.dart';

/// Menampilkan bottom sheet verifikasi PIN 6 digit sebelum melakukan pembayaran QRIS.
/// Mengembalikan `true` jika PIN valid, atau `false` jika dibatalkan.
Future<bool> showQrisPinSheet(
  BuildContext context, {
  String title = 'Masukkan PIN FinPay',
  String? subtitle,
}) async {
  final verified = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _QrisPinSheet(
      title: title,
      subtitle: subtitle,
    ),
  );
  return verified ?? false;
}

class _QrisPinSheet extends StatefulWidget {
  const _QrisPinSheet({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  State<_QrisPinSheet> createState() => _QrisPinSheetState();
}

class _QrisPinSheetState extends State<_QrisPinSheet> {
  static const int _pinLength = 6;
  String _pin = '';
  String? _errorMessage;

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });

    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  void _verifyPin() {
    final isValid = AuthService.instance.validatePin(_pin);
    if (isValid) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _pin = '';
      _errorMessage = 'PIN yang kamu masukkan salah. Silakan coba lagi.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  widget.subtitle!,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PinDots(
                length: _pinLength,
                filled: _pin.length,
                hasError: _errorMessage != null,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Gunakan 6 digit PIN keamanan akun FinPay kamu',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: AppSpacing.xl),
              PinKeypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
