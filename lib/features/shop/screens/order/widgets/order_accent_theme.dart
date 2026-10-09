import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

/// Visual theme for product vs package orders in list and detail screens.
class OrderAccentTheme {
  const OrderAccentTheme({
    required this.kind,
    required this.accentColor,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.badgeIcon,
    required this.badgeLabel,
  });

  final OrderKind kind;
  final Color accentColor;
  final Color badgeBackground;
  final Color badgeForeground;
  final IconData badgeIcon;
  final String badgeLabel;

  static const Color productAccent = Color(0xFF2E7D32);

  factory OrderAccentTheme.forKind(OrderKind kind) {
    if (kind == OrderKind.package) {
      return const OrderAccentTheme(
        kind: OrderKind.package,
        accentColor: IAMColors.primary,
        badgeBackground: Color(0xFFF5E6B8),
        badgeForeground: Color(0xFF8B6914),
        badgeIcon: Iconsax.gift,
        badgeLabel: 'PACKAGE',
      );
    }
    return const OrderAccentTheme(
      kind: OrderKind.product,
      accentColor: productAccent,
      badgeBackground: Color(0xFFDFF0E0),
      badgeForeground: productAccent,
      badgeIcon: Iconsax.shop,
      badgeLabel: 'PRODUCT',
    );
  }

  factory OrderAccentTheme.fromOrderType(String orderType) {
    return OrderAccentTheme.forKind(orderKindFromType(orderType));
  }
}
