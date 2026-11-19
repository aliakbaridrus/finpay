import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Notifikasi & Promo.
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _trxNotif = true;
  bool _promoNotif = true;
  bool _emailNotif = false;

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
        title: Text('Notifikasi & Promo', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notifikasi Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Info masuk/keluar uang & transfer'),
                value: _trxNotif,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _trxNotif = val),
              ),
              const Divider(color: AppColors.border, height: 1),
              SwitchListTile(
                title: const Text('Promo & Diskon Spesial', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Informasi voucher cashback & diskon tagihan'),
                value: _promoNotif,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _promoNotif = val),
              ),
              const Divider(color: AppColors.border, height: 1),
              SwitchListTile(
                title: const Text('Buletin Email Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ringkasan finansial dikirim ke email'),
                value: _emailNotif,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _emailNotif = val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
