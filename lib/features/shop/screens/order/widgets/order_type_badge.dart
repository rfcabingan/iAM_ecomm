import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_accent_theme.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class OrderTypeBadge extends StatelessWidget {
  const OrderTypeBadge({
    super.key,
    required this.kind,
    this.compact = false,
    this.onColoredHeader = false,
  });

  final OrderKind kind;
  final bool compact;
  final bool onColoredHeader;

  @override
  Widget build(BuildContext context) {
    final theme = OrderAccentTheme.forKind(kind);
    final bg = onColoredHeader
        ? Colors.white.withValues(alpha: 0.22)
        : theme.badgeBackground;
    final fg = onColoredHeader ? Colors.white : theme.badgeForeground;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? IAMSizes.sm : IAMSizes.md,
        vertical: compact ? 4 : IAMSizes.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: onColoredHeader
            ? Border.all(color: Colors.white.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            theme.badgeIcon,
            size: compact ? 14 : 16,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            theme.badgeLabel,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
