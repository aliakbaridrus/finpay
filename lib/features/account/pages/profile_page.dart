import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/account_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';

/// Profil Saya terintegrasi [AccountService] & koleksi `users` di Firestore (Bagian Tugas Pidi).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final second = parts.length > 1 ? parts[1][0] : '';
    return (parts.first[0] + second).toUpperCase();
  }

  Future<void> _edit({
    required String label,
    required String current,
    required Future<void> Function(String) onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _EditSheet(
        label: label,
        initial: current,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      await onSaved(result.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label berhasil diperbarui & disimpan ke Firebase')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfileModel>(
      valueListenable: AccountService.instance.userNotifier,
      builder: (context, user, _) {
        return SubPageScaffold(
          title: 'Profil Saya',
          children: [
            _buildAvatar(user.fullName),
            const SizedBox(height: AppSpacing.section),
            Text('Data Sesuai KTP', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  _FieldRow(
                    label: 'Nama Lengkap',
                    value: user.fullName,
                    onEdit: () => _edit(
                      label: 'Nama Lengkap',
                      current: user.fullName,
                      onSaved: (v) =>
                          AccountService.instance.updateProfile(fullName: v),
                    ),
                  ),
                  const _FieldDivider(),
                  _FieldRow(label: 'NIK', value: user.nik),
                  const _FieldDivider(),
                  _FieldRow(label: 'Tanggal Lahir', value: user.birthDate),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Text('Kontak', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  _FieldRow(
                    label: 'Email',
                    value: user.email,
                    onEdit: () => _edit(
                      label: 'Email',
                      current: user.email,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (v) =>
                          AccountService.instance.updateProfile(email: v),
                    ),
                  ),
                  const _FieldDivider(),
                  _FieldRow(
                    label: 'Nomor HP',
                    value: user.phoneNumber,
                    onEdit: () => _edit(
                      label: 'Nomor HP',
                      current: user.phoneNumber,
                      keyboardType: TextInputType.phone,
                      onSaved: (v) =>
                          AccountService.instance.updateProfile(phoneNumber: v),
                    ),
                  ),
                  const _FieldDivider(),
                  _FieldRow(
                    label: 'Alamat',
                    value: user.address,
                    onEdit: () => _edit(
                      label: 'Alamat',
                      current: user.address,
                      maxLines: 3,
                      onSaved: (v) =>
                          AccountService.instance.updateProfile(address: v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            const InfoNote(
              icon: Icons.lock_outline_rounded,
              title: 'Kenapa ada data yang terkunci?',
              text: 'NIK dan tanggal lahir mengikuti data KTP saat '
                  'verifikasi KYC. Untuk mengubahnya, hubungi CS FinPay.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(String fullName) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.balanceGradient,
            boxShadow: AppShadows.glow(AppColors.primary),
          ),
          child: Text(
            _initials(fullName),
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(fullName, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xxs),
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ubah foto belum tersedia (demo)')),
          ),
          child: Text(
            'Ubah Foto',
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Satu baris data. Kalau [onEdit] null, baris dianggap terkunci.
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value, this.onEdit});

  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final locked = onEdit == null;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(value, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              locked ? Icons.lock_outline_rounded : Icons.edit_outlined,
              size: AppSizes.iconMd - 2,
              color: locked ? AppColors.textTertiary : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
      color: AppColors.border,
    );
  }
}

/// Bottom sheet berisi satu TextField. Controller dikelola di sini supaya
/// di-dispose dengan benar saat sheet ditutup.
class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.label,
    required this.initial,
    required this.maxLines,
    this.keyboardType,
  });

  final String label;
  final String initial;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubah ${widget.label}', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ),
                child: Text(
                  'Simpan',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
