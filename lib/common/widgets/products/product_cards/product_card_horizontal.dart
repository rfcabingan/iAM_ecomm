import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/styles/shadows.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMProductCardHorizontal extends StatelessWidget {
  const IAMProductCardHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Container(
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
                /// -- Thumbnail Image
                const SizedBox(
                  height: 120,
                  width: 120,
                  child: IAMRoundedImage(
                    imageUrl: IAMImages.pibarcap,
                    applyImageRadius: true,
                  ),
                ),

                //Sale Tag
                Positioned(
                  top: 7,
                  left: 7,
                  child: IAMRoundedContainer(
                    radius: IAMSizes.sm,
                    backgroundColor: IAMColors.secondary.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: IAMSizes.sm,
                      vertical: IAMSizes.xs,
                    ),
                    child: Text(
                      '25%',
                      style: Theme.of(context).textTheme.labelLarge!.apply(
                        color: const Color.fromARGB(255, 252, 252, 252),
                      ),
                    ),
                  ),
                ),
                //Favourite Icon Button
                const Positioned(
                  top: 0,
                  right: 0,
                  child: IAMCircularIcon(
                    icon: Iconsax.heart5,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          //Details
          SizedBox(
            width: 172,
            child: Padding(
              padding: EdgeInsets.only(top: IAMSizes.sm, left: 0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IAMProductTitleText(
                        title: 'Amazing Pure Organic Barley Drink',
                        smallSize: true,
                      ),
                      SizedBox(height: IAMSizes.spaceBtwItems / 2),
                      IAMBrandTitleWithVerifiedIcon(title: 'Amazing Barley'),
                    ],
                  ),

                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: //Pricing
                    [
                      const Flexible(
                        child: IAMProductPriceText(price: '1,750.00'),
                      ),
                      //Add to cart
                      Container(
                        decoration: const BoxDecoration(
                          color: IAMColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                            bottomRight: Radius.circular(
                              IAMSizes.productImageRadius,
                            ),
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
    );
  }
}
