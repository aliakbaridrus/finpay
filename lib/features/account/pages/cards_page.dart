import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_box.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../widgets/sub_page_scaffold.dart';

class _BankAccount {
  _BankAccount({required this.bank, required this.last4, this.isPrimary = false});

  final String bank;
  final String last4;
  bool isPrimary;
}

/// Rekening & Kartu: kartu virtual FinPay + daftar rekening bank terhubung.
class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool _numberVisible = false;
  bool _frozen = false;
  bool _onlineOn = true;

  final List<_BankAccount> _accounts = [
    _BankAccount(bank: 'BCA', last4: '4821', isPrimary: true),
    _BankAccount(bank: 'Mandiri', last4: '7733'),
  ];

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _makePrimary(_BankAccount account) {
    setState(() {
      for (final item in _accounts) {
        item.isPrimary = identical(item, account);
      }
    });
    _snack('${account.bank} dijadikan rekening utama');
  }

  void _remove(_BankAccount account) {
    if (_accounts.length == 1) {
      _snack('Minimal harus ada satu rekening terhubung');
      return;
    }
    setState(() {
      _accounts.remove(account);
      if (!_accounts.any((a) => a.isPrimary)) {
        _accounts.first.isPrimary = true;
      }
    });
    _snack('Rekening ${account.bank} dihapus');
  }

  Future<void> _addAccount() async {
    final result = await showModalBottomSheet<_BankAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const _AddAccountSheet(),
    );

    if (result != null && mounted) {
      setState(() => _accounts.add(result));
      _snack('Rekening ${result.bank} ditambahkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Rekening & Kartu',
      children: [
        _VirtualCard(
          visible: _numberVisible,
          frozen: _frozen,
          onToggleVisible: () =>
              setState(() => _numberVisible = !_numberVisible),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              _SwitchRow(
                icon: Icons.ac_unit_rounded,
                title: 'Bekukan Kartu',
                subtitle: 'Blokir semua transaksi kartu sementara',
                value: _frozen,
                onChanged: (v) => setState(() => _frozen = v),
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.lg + AppSizes.transactionIconBox + AppSpacing.md,
                color: AppColors.border,
              ),
              _SwitchRow(
                icon: Icons.public_rounded,
                title: 'Transaksi Online',
                subtitle: 'Izinkan pembayaran di merchant online',
                value: _onlineOn,
                onChanged: (v) => setState(() => _onlineOn = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        Text('Rekening Terhubung', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (var i = 0; i < _accounts.length; i++) ...[
                _buildAccountRow(_accounts[i]),
                if (i != _accounts.length - 1)
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
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _addAccount,
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          label: Text(
            'Tambah Rekening',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow(_BankAccount account) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const IconBox(
            icon: Icons.account_balance_rounded,
            size: AppSizes.transactionIconBox,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${account.bank} •••• ${account.last4}',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text('a.n. ${DummyData.userName}', style: AppTextStyles.caption),
              ],
            ),
          ),
          if (account.isPrimary)
            const PillBadge(
              label: 'Utama',
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primary,
            ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textTertiary,
            ),
            color: AppColors.surface,
            onSelected: (value) {
              if (value == 'primary') {
                _makePrimary(account);
              } else {
                _remove(account);
              }
            },
            itemBuilder: (_) => [
              if (!account.isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Text('Jadikan Utama'),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Hapus Rekening'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu virtual FinPay. Nomor bisa disembunyikan, dan ada overlay saat
/// kartu dibekukan.
class _VirtualCard extends StatelessWidget {
  const _VirtualCard({
    required this.visible,
    required this.frozen,
    required this.onToggleVisible,
  });

  final bool visible;
  final bool frozen;
  final VoidCallback onToggleVisible;

  static const String _fullNumber = '4821 3390 5512 0876';
  static const String _maskedNumber = '•••• •••• •••• 0876';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(AppColors.primary),
      ),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: ClipRRect(
          borderRadius: AppRadius.xlAll,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.balanceGradient),
              ),
              Positioned(
                top: -50,
                right: -40,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'FinPay',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        PillBadge(
                          label: 'VIRTUAL',
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        InkWell(
                          onTap: onToggleVisible,
                          borderRadius: AppRadius.pillAll,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            child: Icon(
                              visible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: AppSizes.iconMd - 2,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        visible ? _fullNumber : _maskedNumber,
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DummyData.userName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          '08/29',
                          style: AppTextStyles.label
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (frozen)
                Container(
                  color: AppColors.navy.withValues(alpha: 0.72),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Kartu dibekukan',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: Colors.white),
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconBox(icon: icon, size: AppSizes.transactionIconBox),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet();

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  static const List<String> _banks = ['BNI', 'BRI', 'CIMB Niaga', 'Permata'];

  String _bank = _banks.first;
  final TextEditingController _controller = TextEditingController();

  bool get _valid => _controller.text.length >= 10;

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
            Text('Tambah Rekening', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            Text('Pilih bank', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final bank in _banks)
                  ChoiceChip(
                    label: Text(bank),
                    selected: _bank == bank,
                    onSelected: (_) => setState(() => _bank = bank),
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.label.copyWith(
                      color: _bank == bank
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: _bank == bank
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 16,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Nomor rekening (min. 10 digit)',
                counterText: '',
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
                onPressed: _valid
                    ? () => Navigator.pop(
                          context,
                          _BankAccount(
                            bank: _bank,
                            last4: _controller.text
                                .substring(_controller.text.length - 4),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ),
                child: Text(
                  'Tambahkan',
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
