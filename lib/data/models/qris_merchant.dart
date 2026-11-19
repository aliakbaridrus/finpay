import 'package:flutter/material.dart';

import 'qris_model.dart';

/// Merchant uji coba untuk simulasi pemindaian QRIS di FinPay.
class QrisMerchant {
  const QrisMerchant({
    required this.name,
    required this.city,
    required this.nmid,
    required this.category,
    required this.icon,
    required this.suggestedAmount,
    required this.isDynamic,
    this.mcc = '5812',
  });

  final String name;
  final String city;
  final String nmid;
  final String category;
  final IconData icon;

  /// Nominal contoh. Dipakai sebagai nominal terkunci jika [isDynamic] true.
  final int suggestedAmount;

  /// `true` = QRIS dinamis (nominal terkunci), `false` = QRIS statis.
  final bool isDynamic;
  final String mcc;

  QrisPayload toPayload({String? referenceLabel}) {
    return QrisPayload(
      merchantName: name,
      merchantCity: city,
      nmid: nmid,
      merchantCategoryCode: mcc,
      amount: isDynamic ? suggestedAmount : null,
      referenceLabel: referenceLabel,
      terminalLabel: 'FINPAY01',
    );
  }

  /// String QRIS yang dihasilkan seolah-olah dipindai dari kasir merchant.
  String get qrisString => toPayload().encode();
}

/// Katalog merchant uji coba.
abstract final class QrisMerchantCatalog {
  static const List<QrisMerchant> merchants = [
    QrisMerchant(
      name: 'Kopi Kenangan Sudirman',
      city: 'Jakarta Pusat',
      nmid: 'ID1020023912901',
      category: 'Kafe & Restoran',
      icon: Icons.local_cafe_rounded,
      suggestedAmount: 45000,
      isDynamic: true,
    ),
    QrisMerchant(
      name: 'Indomaret Point Kuningan',
      city: 'Jakarta Selatan',
      nmid: 'ID1020031120455',
      category: 'Minimarket',
      icon: Icons.storefront_rounded,
      suggestedAmount: 87500,
      isDynamic: true,
      mcc: '5411',
    ),
    QrisMerchant(
      name: 'Alfamart Cikini',
      city: 'Jakarta Pusat',
      nmid: 'ID1020028834120',
      category: 'Minimarket',
      icon: Icons.shopping_basket_rounded,
      suggestedAmount: 0,
      isDynamic: false,
      mcc: '5411',
    ),
    QrisMerchant(
      name: 'SPBU Pertamina 31.101',
      city: 'Jakarta Barat',
      nmid: 'ID1020019987213',
      category: 'Bahan Bakar',
      icon: Icons.local_gas_station_rounded,
      suggestedAmount: 0,
      isDynamic: false,
      mcc: '5541',
    ),
    QrisMerchant(
      name: 'Warung Bu Siti',
      city: 'Bandung',
      nmid: 'ID1020044501987',
      category: 'Warung Makan',
      icon: Icons.ramen_dining_rounded,
      suggestedAmount: 0,
      isDynamic: false,
    ),
  ];
}
