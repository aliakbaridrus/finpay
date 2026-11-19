import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Keamanan & PIN.
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Keamanan & PIN', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    title: const Text('Ubah PIN FinPay', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Perbarui 6 digit PIN transaksi'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka form Ubah PIN...')),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    title: const Text('Login Biometrik / Face ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Masuk aplikasi menggunakan sidik jari'),
                    value: _biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.verified_user_rounded, color: AppColors.primary),
                    title: const Text('Autentikasi 2 Faktor (2FA)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('OTP tambahan saat transaksi besar'),
                    value: _twoFactorEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _twoFactorEnabled = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
