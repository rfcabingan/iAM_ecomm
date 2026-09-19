import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iam_ecomm/common/styles/shadows.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/features/shop/screens/packages/package_detail.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMPackageCard extends StatelessWidget {
  const IAMPackageCard({super.key, required this.package});

  final PackageItem package;

  static String _formatPrice(num value) {
    return NumberFormat('#,##0.00', 'en_PH').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(
        () => PackageDetailScreen(package: package),
      ),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [IAMShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(IAMSizes.productImageRadius),
          color: dark ? IAMColors.darkerGrey : IAMColors.white,
        ),
        child: Column(
          children: [
            IAMRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(IAMSizes.sm),
              backgroundColor: dark ? IAMColors.dark : IAMColors.light,
              child: Stack(
                children: [
                  IAMRoundedImage(
                    imageUrl: package.imageUrl,
                    applyImageRadius: true,
                    isNetworkImage: true,
                  ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: IAMRoundedContainer(
                      radius: IAMSizes.sm,
                      backgroundColor: IAMColors.primary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: IAMSizes.sm,
                        vertical: IAMSizes.xs,
                      ),
                      child: Text(
                        'Package',
                        style: Theme.of(context).textTheme.labelLarge!.apply(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            Padding(
              padding: const EdgeInsets.only(left: IAMSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IAMProductTitleText(
                    title: package.packageName,
                    smallSize: true,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                  Text(
                    package.packageDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? IAMColors.lightGrey : IAMColors.darkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: IAMSizes.sm),
                  child: IAMProductPriceText(
                    price: _formatPrice(package.packageAmount),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: IAMColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                      bottomRight: Radius.circular(
                        IAMSizes.productImageRadius,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: IAMSizes.iconLg * 1.2,
                    height: IAMSizes.iconLg * 1.2,
                    child: const Center(
                      child: Icon(Icons.arrow_forward, color: IAMColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}