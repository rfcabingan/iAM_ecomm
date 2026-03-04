import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/features/shop/controllers/wishlist_controller.dart';
import 'package:iam_ecomm/features/shop/models/product_model.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/product_detail.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMProductCardHorizontal extends StatelessWidget {
  const IAMProductCardHorizontal({super.key, required this.product});

  final IAMProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IAMSizes.productImageRadius),
          color: dark ? IAMColors.darkerGrey : IAMColors.softGrey,
        ),
        child: Row(
          children: [
            ///Thumbnail
            IAMRoundedContainer(
              height: 120,
              padding: const EdgeInsets.all(IAMSizes.sm),
              backgroundColor: dark ? IAMColors.dark : IAMColors.light,
              child: Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: IAMRoundedImage(
                      imageUrl: product.imageUrl,
                      applyImageRadius: true,
                    ),
                  ),
                  if (product.discountPercentage != null &&
                      product.discountPercentage! > 0)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: IAMRoundedContainer(
                        radius: IAMSizes.sm,
                        backgroundColor:
                            IAMColors.secondary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: IAMSizes.sm,
                          vertical: IAMSizes.xs,
                        ),
                        child: Text(
                          '${product.discountPercentage!.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color: const Color.fromARGB(255, 252, 252, 252),
                              ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
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

            //Details
            SizedBox(
              width: 172,
              child: Padding(
                padding: EdgeInsets.only(top: IAMSizes.sm, left: 0,),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: IAMSizes.sm,
                          ),
                          child: IAMProductTitleText(
                            title: product.title,
                            smallSize: true,
                          ),
                        ),
                        SizedBox(height: IAMSizes.spaceBtwItems / 2),
                        IAMBrandTitleWithVerifiedIcon(title: product.brand),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: IAMProductPriceText(
                              price: product.price.toStringAsFixed(2)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: IAMColors.dark,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                              bottomRight: Radius.circular(
                                  IAMSizes.productImageRadius),
                            ),
                          ),
                          child: const SizedBox(
                            width: IAMSizes.iconLg * 1.2,
                            height: IAMSizes.iconLg * 1.2,
                            child: Center(
                              child: Icon(Iconsax.add, color: IAMColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
