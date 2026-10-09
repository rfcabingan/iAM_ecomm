import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_filters.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_accent_theme.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_summary_row.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_type_badge.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

bool orderItemIsUnpaid(OrderItem order) {
  return order.paymentStatusId == PaymentStatusIds.pending ||
      order.paymentStatusId == PaymentStatusIds.failed ||
      order.paymentStatusId == 0 ||
      order.paymentStatusName.toLowerCase() == 'not paid' ||
      order.paymentStatusName.toLowerCase().contains('awaiting');
}

String orderPaymentStatusLabel(OrderItem order, {required bool isUnpaid}) {
  if (order.paymentStatusName.trim().isNotEmpty) {
    return order.paymentStatusName.trim();
  }
  return isUnpaid ? 'Awaiting payment' : 'Paid';
}

class OrderListCard extends StatelessWidget {
  const OrderListCard({
    super.key,
    required this.order,
    required this.formatter,
    required this.onTap,
    this.statusSubtitle = "We're processing your order now!",
    this.onPayNow,
    this.showPayNow = true,
  });

  final OrderItem order;
  final NumberFormat formatter;
  final VoidCallback onTap;
  final String statusSubtitle;
  final Future<bool> Function()? onPayNow;
  final bool showPayNow;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final theme = OrderAccentTheme.forKind(order.kind);
    final isUnpaid = orderItemIsUnpaid(order);
    final paymentLabel = orderPaymentStatusLabel(order, isUnpaid: isUnpaid);

    return GestureDetector(
      onTap: onTap,
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.md),
        backgroundColor: dark ? IAMColors.dark : IAMColors.light,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '#${order.orderRefno}',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                      fontWeightDelta: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderRefno));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Order number copied!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green[300],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.copy),
                  iconSize: IAMSizes.iconSm,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const SizedBox(width: IAMSizes.xs),
                OrderTypeBadge(kind: order.kind),
              ],
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            OrderSummaryRow(order: order),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.routing,
                    size: 20,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderStatusName,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .apply(
                                    color: theme.accentColor,
                                    fontWeightDelta: 1,
                                  ),
                            ),
                          ),
                          const Tooltip(
                            message: 'Click on the card to View Details',
                            child: Icon(
                              Iconsax.arrow_right_3,
                              size: 18,
                              color: IAMColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusSubtitle,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: IAMColors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.calendar,
                    size: 20,
                    color: IAMColors.darkGrey,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Text(
                  DateFormat('dd-MMM-yyyy, hh:mma').format(
                    DateTime.parse(order.orderDate),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Total: ${formatter.format(order.totalAmount)}',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                      fontWeightDelta: 1,
                      color: IAMColors.dark,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUnpaid ? Iconsax.clock : Iconsax.tick_circle,
                          size: 18,
                          color: isUnpaid
                              ? IAMColors.warning
                              : IAMColors.success,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            paymentLabel,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.labelLarge!
                                .apply(
                                  color: isUnpaid
                                      ? IAMColors.warning
                                      : IAMColors.success,
                                  fontWeightDelta: 1,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (showPayNow && isUnpaid && onPayNow != null) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () async {
                          await onPayNow!();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.accentColor,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Pay now'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
