import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import 'widgets/account_header_card.dart';
import 'widgets/account_menu_group.dart';
import 'widgets/account_security_card.dart';
import 'widgets/logout_dialog.dart';

/// Halaman Akun & Pengaturan User FinPay.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static final List<AccountMenuSectionData> _menuSections = [
    AccountMenuSectionData(
      title: 'AKUN & KEAMANAN',
      items: [
        AccountMenuItemData(
          title: 'Data Diri & Profil',
          subtitle: 'KTP, NIK, Email, dan Tanggal Lahir',
          icon: Icons.person_outline_rounded,
        ),
        AccountMenuItemData(
          title: 'Rekening & Kartu Terhubung',
          subtitle: 'BCA, Mandiri, dan Kartu Kredit Visa',
          icon: Icons.credit_card_rounded,
          badgeText: '3 Terhubung',
        ),
        AccountMenuItemData(
          title: 'Keamanan & PIN',
          subtitle: 'Ubah PIN FinPay, Biometrik, & 2FA',
          icon: Icons.lock_outline_rounded,
        ),
      ],
    ),
    AccountMenuSectionData(
      title: 'PENGATURAN APLIKASI',
      items: [
        AccountMenuItemData(
          title: 'Notifikasi & Promo',
          subtitle: 'Atur pesan transaksi dan penawaran khusus',
          icon: Icons.notifications_none_rounded,
        ),
        AccountMenuItemData(
          title: 'Bahasa / Language',
          subtitle: 'Bahasa Indonesia',
          icon: Icons.language_rounded,
        ),
        AccountMenuItemData(
          title: 'Tampilan & Tema',
          subtitle: 'Mode Terang (Light Mode)',
          icon: Icons.brightness_6_rounded,
        ),
      ],
    ),
    AccountMenuSectionData(
      title: 'BANTUAN & INFORMASI',
      items: [
        AccountMenuItemData(
          title: 'Pusat Bantuan (FinCare 24/7)',
          subtitle: 'Tanya CS, FAQ, & Laporan Kendala',
          icon: Icons.headset_mic_outlined,
          badgeText: '24/7 CS',
        ),
        AccountMenuItemData(
          title: 'Syarat & Kebijakan Privasi',
          subtitle: 'Ketentuan penggunaan & legalitas OJK',
          icon: Icons.gavel_rounded,
        ),
        AccountMenuItemData(
          title: 'Tentang Aplikasi FinPay',
          subtitle: 'Versi 1.0.0 (Tersertifikasi LPS & OJK)',
          icon: Icons.info_outline_rounded,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxContentWidth,
          ),
          child: CustomScrollView(
            slivers: [
              // Header Title
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Akun Saya', style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Kelola profil, keamanan, dan pengaturan aplikasi',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),

              // Content List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: [
                    // Header Profil Card
                    AccountHeaderCard(
                      userName: DummyData.userName,
                      phoneNumber: DummyData.phoneNumber,
                      membership: DummyData.membership,
                      points: DummyData.finPoin,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Status Keamanan KYC
                    const AccountSecurityCard(),
                    const SizedBox(height: AppSpacing.section),

                    // Daftar Menu Terkelompok
                    for (final section in _menuSections) ...[
                      AccountMenuGroup(section: section),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    // Tombol Keluar
                    OutlinedButton.icon(
                      onPressed: () => LogoutDialog.show(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: AppSizes.iconMd,
                        color: AppColors.danger,
                      ),
                      label: Text(
                        'Keluar dari Akun',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.dangerLight),
                        backgroundColor: AppColors.dangerLight.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.pillAll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
