import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/enums.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMProductMetaData extends StatelessWidget {
  const IAMProductMetaData({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- PRICE & SALE PRICE
        Row(
          children: [
            // -- SALE TAG
            IAMRoundedContainer(
              radius: IAMSizes.sm,
              backgroundColor: IAMColors.primary.withOpacity(0.8),
              padding: EdgeInsets.symmetric(
                horizontal: IAMSizes.sm,
                vertical: IAMSizes.xs,
              ),
              child: Text(
                '50%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.apply(color: IAMColors.black),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems,),

            // -- PRICE
            Text('₱1,000.00', style: Theme.of(context).textTheme.titleSmall!.apply(decoration: TextDecoration.lineThrough),),
            const SizedBox(width: IAMSizes.spaceBtwItems,),
            const IAMProductPriceText(price: '500', isLarge: true,),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

        // -- TITLE
        const IAMProductTitleText(title: 'IAM Pure Organic Barley Powder'),
        const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

        // -- STOCK STATUS
        Row(
          children: [
            const IAMProductTitleText(title: 'Status'),
            const SizedBox(width: IAMSizes.spaceBtwItems,),
            Text('In Stock', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

        // -- BRAND
        Row(
          children: [
           //IAMCircularImage(image: IAMImages.amazingBarley, width: 32, height: 32, overlayColor: darkMode ? IAMColors.white : IAMColors.black,),
            const IAMBrandTitleWithVerifiedIcon(title: 'AMAZING BARLEY', brandTextSize: TextSizes.medium,),
          ],
        )
      ],
    );
  }
}
