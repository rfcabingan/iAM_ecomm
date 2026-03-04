import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iam_ecomm/common/styles/shadows.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/product_detail.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/features/shop/models/product_model.dart';
import 'package:iam_ecomm/features/shop/controllers/wishlist_controller.dart';

class IAMProductCardVertical extends StatelessWidget {
  const IAMProductCardVertical({super.key, required this.product,});
  final IAMProductModel product;
  

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
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
            //thumbnail, whishlist button, discount tag
            IAMRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(IAMSizes.sm),
              backgroundColor: dark ? IAMColors.dark : IAMColors.light,
              child: Stack(
                children: [
                  //thumbnail
                  IAMRoundedImage(
                    imageUrl: product.imageUrl,
                    applyImageRadius: true,
                  ),

                  //sale tag
                 if (product.discountPercentage != null && product.discountPercentage! > 0)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: IAMRoundedContainer(
                        radius: IAMSizes.sm,
                        backgroundColor: const Color.fromARGB(
                          255,
                          24,
                          24,
                          24,
                        ).withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: IAMSizes.sm,
                          vertical: IAMSizes.xs,
                        ),
                        child: Text(
                          '${product.discountPercentage!.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                  //Favourite Icon Button
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Obx(() {
                      final wishlisted =
                          WishlistController.instance.isWishlisted(product.id);
                      return IAMCircularIcon(
                        icon: wishlisted ? Iconsax.heart5 : Iconsax.heart,
                        color: wishlisted ? Colors.red : IAMColors.grey,
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            // details
            Padding(
              padding: const EdgeInsets.only(left: IAMSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IAMProductTitleText(
                    title: product.title,
                    smallSize: true,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                  IAMBrandTitleWithVerifiedIcon(title: product.brand),
                ],
              ),
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Price
                Padding(
                  padding: const EdgeInsets.only(left: IAMSizes.sm),
                  child: IAMProductPriceText(price: product.price.toString()),
                ),

                //add to cart button
                Container(
                  decoration: const BoxDecoration(
                    color: IAMColors.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                      bottomRight: Radius.circular(IAMSizes.productImageRadius),
                    ),
                  ),
                  child: SizedBox(
                    width: IAMSizes.iconLg * 1.2,
                    height: IAMSizes.iconLg * 1.2,
                    child: Center(
                      child: const Icon(Iconsax.add, color: IAMColors.white),
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
