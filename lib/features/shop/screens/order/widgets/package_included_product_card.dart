import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

/// Line card for a product included in a package option (matches package detail).
class PackageIncludedProductCard extends StatelessWidget {
  const PackageIncludedProductCard({
    super.key,
    required this.dark,
    required this.name,
    required this.qty,
    required this.imageUrl,
    this.accentColor,
  });

  final bool dark;
  final String name;
  final int qty;
  final String imageUrl;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.sm),
      decoration: BoxDecoration(
        color: accentColor != null
            ? accentColor!.withValues(alpha: 0.08)
            : (dark ? IAMColors.dark : IAMColors.white),
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? IAMColors.darkGrey : IAMColors.borderPrimary,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: dark ? IAMColors.darkerGrey : IAMColors.light,
              borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Iconsax.box,
                        color: dark ? IAMColors.grey : IAMColors.darkGrey,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.box,
                    color: dark ? IAMColors.grey : IAMColors.darkGrey,
                  ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $qty',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.lightGrey : IAMColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
