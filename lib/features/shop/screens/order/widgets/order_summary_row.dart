import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OrderSummaryRow extends StatelessWidget {
  const OrderSummaryRow({
    super.key,
    required this.order,
  });

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final isPackage = order.isPackageOrder;

    final title = isPackage
        ? (order.packageName.isNotEmpty ? order.packageName : 'Package order')
        : _productTitle();
    final subtitle = isPackage
        ? order.optionName
        : (order.itemCount > 0 ? 'Qty: ${order.itemCount}' : '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderThumbnail(imageUrl: order.imageUrl, dark: dark),
        const SizedBox(width: IAMSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.lightGrey : IAMColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _productTitle() {
    final count = order.itemCount;
    if (count <= 0) return 'Product order';
    if (count == 1) return 'Product order';
    return '$count items';
  }
}

class _OrderThumbnail extends StatelessWidget {
  const _OrderThumbnail({
    required this.imageUrl,
    required this.dark,
  });

  final String imageUrl;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: dark ? IAMColors.darkerGrey : IAMColors.softGrey,
        borderRadius: BorderRadius.circular(IAMSizes.sm),
      ),
      child: Icon(
        Iconsax.box,
        color: dark ? IAMColors.grey : IAMColors.darkGrey,
        size: 24,
      ),
    );

    if (imageUrl.trim().isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(IAMSizes.sm),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
