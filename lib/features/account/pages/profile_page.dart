import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../account_data.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';

/// Profil Saya: data diri dari KTP (terkunci) dan kontak (bisa diubah).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _email = AccountDummy.email;
  String _phone = DummyData.phoneNumber;
  String _address = 'Jl. Melati No. 12, Jakarta Selatan';

  String get _initials {
    final parts = DummyData.userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final second = parts.length > 1 ? parts[1][0] : '';
    return (parts.first[0] + second).toUpperCase();
  }

  Future<void> _edit({
    required String label,
    required String current,
    required ValueChanged<String> onSaved,
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
      setState(() => onSaved(result.trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label berhasil diperbarui')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Profil Saya',
      children: [
        _buildAvatar(),
        const SizedBox(height: AppSpacing.section),
        Text('Data Sesuai KTP', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children:  [
              _FieldRow(label: 'Nama Lengkap', value: DummyData.userName),
              _FieldDivider(),
              _FieldRow(label: 'NIK', value: '3174 •••• •••• 0001'),
              _FieldDivider(),
              _FieldRow(label: 'Tanggal Lahir', value: '14 Agustus 2001'),
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
                value: _email,
                onEdit: () => _edit(
                  label: 'Email',
                  current: _email,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _email = v,
                ),
              ),
              const _FieldDivider(),
              _FieldRow(
                label: 'Nomor HP',
                value: _phone,
                onEdit: () => _edit(
                  label: 'Nomor HP',
                  current: _phone,
                  keyboardType: TextInputType.phone,
                  onSaved: (v) => _phone = v,
                ),
              ),
              const _FieldDivider(),
              _FieldRow(
                label: 'Alamat',
                value: _address,
                onEdit: () => _edit(
                  label: 'Alamat',
                  current: _address,
                  maxLines: 3,
                  onSaved: (v) => _address = v,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        const InfoNote(
          icon: Icons.lock_outline_rounded,
          title: 'Kenapa ada data yang terkunci?',
          text: 'Nama, NIK, dan tanggal lahir mengikuti data KTP saat '
              'verifikasi. Untuk mengubahnya, hubungi CS FinPay.',
        ),
      ],
    );
  }

  Widget _buildAvatar() {
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
            _initials,
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(DummyData.userName, style: AppTextStyles.h2),
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
