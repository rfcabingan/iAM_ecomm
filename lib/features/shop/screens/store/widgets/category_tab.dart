import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_showcase.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/data/products_data.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCategoryTab extends StatelessWidget {
  /// When true, only packages are shown. When false, only products are shown.
  /// categoryName filters products by brand when provided.
  const IAMCategoryTab({
    super.key,
    this.showPackagesOnly = false,
    this.categoryName,
  });

  final bool showPackagesOnly;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    // Packages should be displayed in hierarchy order (Copper -> Bronze -> Silver -> Gold -> Platinum -> Jade)
    // Products filtered by category/brand if provided, otherwise all products
    final items = showPackagesOnly
        ? IAMProductsData.packages
        : (categoryName != null
            ? IAMProductsData.getProductsByBrand(categoryName!)
            : IAMProductsData.getShuffledProducts());

    return ListView(
      padding: const EdgeInsets.all(IAMSizes.defaultSpace),
      children: [
        /*IAMBrandShowCase(
          images: [
            IAMImages.pibarcap,
            IAMImages.pibarcho,
            IAMImages.piacaibr,
          ],
        ),*/
        const SizedBox(height: IAMSizes.spaceBtwItems),
        IAMSectionHeading(
          title: showPackagesOnly
              ? 'Packages'
              : (categoryName ?? 'You might like'),
          onPressed: () {},
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        IAMGridLayout(
          itemCount: items.length,
          itemBuilder: (_, index) => IAMProductCardVertical(
            product: items[index],
          ),
        ),
        const SizedBox(height: IAMSizes.spaceBtwSections),
      ],
    );
  }
}
