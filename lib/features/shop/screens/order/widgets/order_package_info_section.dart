import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_accent_theme.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OrderPackageInfoSection extends StatelessWidget {
  const OrderPackageInfoSection({
    super.key,
    required this.display,
  });

  final OrderPackageDisplay display;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: dark ? IAMColors.dark : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: IAMSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PackageImage(imageUrl: display.imageUrl, dark: dark),
              const SizedBox(width: IAMSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display.packageName.isNotEmpty
                          ? display.packageName
                          : 'Package',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (display.optionName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        display.optionName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark
                              ? IAMColors.lightGrey
                              : IAMColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageImage extends StatelessWidget {
  const _PackageImage({required this.imageUrl, required this.dark});

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
      child: Icon(Iconsax.gift, color: OrderAccentTheme.forKind(OrderKind.package).accentColor),
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
