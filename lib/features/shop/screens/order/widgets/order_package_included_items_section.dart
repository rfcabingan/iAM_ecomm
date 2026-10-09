import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/package_included_product_card.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

/// Loads and lists products included in the ordered package option.
class OrderPackageIncludedItemsSection extends StatelessWidget {
  const OrderPackageIncludedItemsSection({
    super.key,
    required this.packageCode,
    required this.optionId,
    required this.accentColor,
    this.fallbackItems = const [],
  });

  final String packageCode;
  final int optionId;
  final Color accentColor;
  final List<OrderProductItem?> fallbackItems;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    if (packageCode.isEmpty || optionId <= 0) {
      return _FallbackOrderItems(
        dark: dark,
        accentColor: accentColor,
        items: fallbackItems,
      );
    }

    return FutureBuilder(
      future: ApiMiddleware.packages.getOptionItems(
        packageCode: packageCode,
        optionId: optionId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: IAMSizes.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final included = (snapshot.data?.data ?? [])
            .whereType<PackageOptionItemDetail>()
            .toList()
          ..sort(
            (a, b) => a.displayOrder.compareTo(b.displayOrder),
          );

        if (included.isEmpty) {
          return _FallbackOrderItems(
            dark: dark,
            accentColor: accentColor,
            items: fallbackItems,
          );
        }

        return Column(
          children: [
            for (final item in included) ...[
              PackageIncludedProductCard(
                dark: dark,
                name: item.productName,
                qty: item.qty,
                imageUrl: item.imageUrl,
                accentColor: accentColor,
              ),
              const SizedBox(height: IAMSizes.sm),
            ],
          ],
        );
      },
    );
  }
}

class _FallbackOrderItems extends StatelessWidget {
  const _FallbackOrderItems({
    required this.dark,
    required this.accentColor,
    required this.items,
  });

  final bool dark;
  final Color accentColor;
  final List<OrderProductItem?> items;

  @override
  Widget build(BuildContext context) {
    final lines = items.whereType<OrderProductItem>().toList();
    if (lines.isEmpty) {
      return Text(
        'No included items listed for this package.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: [
        for (final item in lines) ...[
          PackageIncludedProductCard(
            dark: dark,
            name: item.productName,
            qty: item.qty,
            imageUrl: item.imageUrl,
            accentColor: accentColor,
          ),
          const SizedBox(height: IAMSizes.sm),
        ],
      ],
    );
  }
}
