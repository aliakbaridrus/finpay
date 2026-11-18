import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/auth_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Autentikasi FinPay (Login & Register Email/Password - Bagian Tugas Pidi).
///
/// Terhubung ke [AuthService] dan membuat dokumen profil (`users`) serta
/// saldo awal (`wallets`) saat pengguna baru mendaftar.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _isLoading = false;

  // Seluruh field dikosongkan sejak awal; instruksi pengisian menggunakan hintText (placeholder).
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _toggleMode(bool registerMode) {
    setState(() {
      _isRegisterMode = registerMode;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1945),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDateController.text = AuthService.formatDeviceDate(picked);
      });
    }
  }

  Future<void> _submitAuth() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    try {
      if (_isRegisterMode) {
        final user = await AuthService.instance.register(
          fullName: _nameController.text,
          nik: _nikController.text,
          birthDate: _birthDateController.text,
          address: _addressController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          password: _passwordController.text,
          pin: _pinController.text,
          usedReferralCode: _referralController.text,
          initialCash: 0,
        );
        if (!mounted) return;
        final bonusNote = user.finPoin > 0
            ? ' + Bonus Referral ${user.finPoin} FinPoin!'
            : ' (Saldo Awal Rp 0)!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akun ${user.fullName} berhasil terdaftar pada ${user.memberSince}$bonusNote',
            ),
          ),
        );
      } else {
        final user = await AuthService.instance.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang kembali, ${user.fullName}!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = AuthService.formatDeviceDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildBrandHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildModeSwitcher(),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRegisterMode
                              ? 'Buat Akun Baru FinPay'
                              : 'Masuk ke Akun Kamu',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _isRegisterMode
                              ? 'Lengkapi data diri sesuai KTP. Tanggal daftar mengikuti perangkat ($todayFormatted) dengan saldo awal Rp 0.'
                              : 'Gunakan email & password terdaftar untuk memuat kembali saldo & riwayatmu.',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (_isRegisterMode) ...[
                          TextField(
                            controller: _nameController,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap Sesuai KTP',
                              hintText: 'Isi nama lengkap di sini (cth: Budi Santoso)',
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _nikController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 16,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'NIK KTP (16 Digit)',
                              hintText: 'Masukkan 16 digit NIK KTP kamu',
                              counterText: '',
                              prefixIcon: const Icon(
                                Icons.credit_card_rounded,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _birthDateController,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Lahir',
                              hintText: 'Cth: 14 Agustus 2001 (atau klik ikon kalender)',
                              prefixIcon: const Icon(
                                Icons.cake_outlined,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                tooltip: 'Pilih Tanggal Lahir',
                                onPressed: _pickBirthDate,
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _addressController,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Alamat / Lokasi Tempat Tinggal',
                              hintText: 'Isi alamat & kota tempat tinggal (cth: Jl. Melati No. 12, Jakarta)',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            labelText: 'Alamat Email',
                            hintText: 'Masukkan email kamu (cth: nama@email.com)',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                        ),
                        if (_isRegisterMode) ...[
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Nomor HP Aktif',
                              hintText: 'Masukkan nomor HP (cth: 0812-3456-7890)',
                              prefixIcon: const Icon(
                                Icons.phone_android_rounded,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Masukkan password (minimal 6 karakter)',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                        ),
                        if (_isRegisterMode) ...[
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: _obscurePin,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Buat PIN Transaksi (6 Digit Angka)',
                              hintText: 'Masukkan 6 digit angka PIN keamanan',
                              counterText: '',
                              prefixIcon: const Icon(
                                Icons.pin_outlined,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePin = !_obscurePin,
                                ),
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _referralController,
                            textCapitalization: TextCapitalization.characters,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              labelText: 'Kode Referral Teman (Opsional)',
                              hintText:
                                  'Masukkan kode referral teman (cth: FINPAY-REZA25) untuk bonus +500 FinPoin',
                              prefixIcon: const Icon(
                                Icons.redeem_rounded,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitAuth,
                            icon: Icon(
                              _isRegisterMode
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.login_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isLoading
                                  ? 'Memproses Autentikasi...'
                                  : (_isRegisterMode
                                      ? 'Daftar & Buat Dompet'
                                      : 'Masuk ke FinPay'),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const StadiumBorder(),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickDemoNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const PillBadge(
                label: 'Firebase Auth • OJK',
                leadingIcon: Icons.verified_user_rounded,
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'FinPay Digital Wallet',
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Solusi pembayaran QRIS, tabungan impian, & manajemen arus kas modern.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthTabButton(
              label: 'Masuk (Login)',
              selected: !_isRegisterMode,
              onTap: () => _toggleMode(false),
            ),
          ),
          Expanded(
            child: _AuthTabButton(
              label: 'Daftar Baru',
              selected: _isRegisterMode,
              onTap: () => _toggleMode(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _isRegisterMode
                  ? 'Akun baru akan memulai dengan Saldo Rp 0. Kamu dapat langsung melakukan Top Up atau menerima transfer setelah mendaftar.'
                  : 'Untuk masuk sebagai user lama (Reza Pratama), ketik email: reza.pratama@email.com dan password: password123.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
