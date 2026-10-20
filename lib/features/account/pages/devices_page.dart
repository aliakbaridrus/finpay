import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';

class _Device {
  const _Device({
    required this.name,
    required this.detail,
    required this.icon,
    this.isCurrent = false,
  });

  final String name;
  final String detail;
  final IconData icon;
  final bool isCurrent;
}

/// Perangkat Terpercaya: daftar perangkat yang pernah login, dan opsi
/// mengeluarkan perangkat yang tidak dikenali.
class TrustedDevicesPage extends StatefulWidget {
  const TrustedDevicesPage({super.key});

  @override
  State<TrustedDevicesPage> createState() => _TrustedDevicesPageState();
}

class _TrustedDevicesPageState extends State<TrustedDevicesPage> {
  final List<_Device> _devices = [
    const _Device(
      name: 'MacBook Pro',
      detail: 'Chrome • Jakarta, ID • Aktif sekarang',
      icon: Icons.laptop_mac_rounded,
      isCurrent: true,
    ),
    const _Device(
      name: 'iPhone 13',
      detail: 'Aplikasi FinPay • Aktif 2 jam lalu',
      icon: Icons.smartphone_rounded,
    ),
    const _Device(
      name: 'Redmi Note 11',
      detail: 'Aplikasi FinPay • Aktif 5 hari lalu',
      icon: Icons.smartphone_rounded,
    ),
  ];

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        title: Text(title, style: AppTextStyles.h2),
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Batal',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: AppTextStyles.label.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _remove(_Device device) async {
    final ok = await _confirm(
      title: 'Keluarkan ${device.name}?',
      message: 'Perangkat ini akan otomatis logout dan perlu verifikasi '
          'ulang untuk masuk lagi.',
      confirmLabel: 'Keluarkan',
    );
    if (!ok || !mounted) return;
    setState(() => _devices.remove(device));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${device.name} dikeluarkan')),
    );
  }

  Future<void> _removeAllOthers() async {
    final ok = await _confirm(
      title: 'Keluarkan semua perangkat lain?',
      message: 'Hanya perangkat yang sedang kamu pakai yang tetap login.',
      confirmLabel: 'Keluarkan Semua',
    );
    if (!ok || !mounted) return;
    setState(() => _devices.removeWhere((d) => !d.isCurrent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua perangkat lain dikeluarkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasOthers = _devices.any((d) => !d.isCurrent);

    return SubPageScaffold(
      title: 'Perangkat Terpercaya',
      children: [
        Text('${_devices.length} perangkat aktif', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (var i = 0; i < _devices.length; i++) ...[
                _buildDeviceRow(_devices[i]),
                if (i != _devices.length - 1)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg +
                        AppSizes.transactionIconBox +
                        AppSpacing.md,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
        if (hasOthers) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: _removeAllOthers,
            icon: const Icon(Icons.logout_rounded, size: AppSizes.iconMd),
            label: Text(
              'Keluarkan Semua Perangkat Lain',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.danger),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.dangerLight,
              foregroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        const InfoNote(
          icon: Icons.shield_outlined,
          title: 'Lihat perangkat asing?',
          text: 'Segera keluarkan perangkat yang tidak kamu kenali, lalu '
              'ubah PIN FinPay kamu untuk menjaga keamanan akun.',
        ),
      ],
    );
  }

  Widget _buildDeviceRow(_Device device) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconBox(icon: device.icon, size: AppSizes.transactionIconBox),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(device.name, style: AppTextStyles.bodyLarge),
                    ),
                    if (device.isCurrent) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const PillBadge(
                        label: 'Perangkat ini',
                        backgroundColor: AppColors.successLight,
                        foregroundColor: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(device.detail, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (!device.isCurrent)
            IconButton(
              tooltip: 'Keluarkan perangkat',
              onPressed: () => _remove(device),
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
