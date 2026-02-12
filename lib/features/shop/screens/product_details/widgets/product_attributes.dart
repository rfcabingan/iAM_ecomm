import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/chips/choice_chip.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMProductAttributes extends StatelessWidget {
  const IAMProductAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        // -- SELECTED ATTRIBUTE PRICING & DESCRIPTION
        IAMRoundedContainer(
          padding: const EdgeInsets.all(IAMSizes.md),
          backgroundColor: dark ? IAMColors.darkerGrey : IAMColors.grey,
          child: Column(
            children: [
              // -- TITLE PRICE & STOCK STATUS
              Row(
                children: [
                  const IAMSectionHeading(
                    title: 'Variation',
                    showActionButton: false,
                  ),
                  const SizedBox(width: IAMSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IAMProductTitleText(
                            title: 'Price : ',
                            smallSize: true,
                          ),
                          const SizedBox(width: IAMSizes.spaceBtwItems),
                          // -- ACTUAL PRICE
                          Text(
                            '₱1,000.00',
                            style: Theme.of(context).textTheme.titleSmall!
                                .apply(decoration: TextDecoration.lineThrough),
                          ),

                          const SizedBox(width: IAMSizes.spaceBtwItems),

                          // -- SALE PRICE
                          IAMProductPriceText(price: '500.00'),
                        ],
                      ),

                      // -- STOCK
                      Row(
                        children: [
                          const IAMProductTitleText(
                            title: 'Stock : ',
                            smallSize: true,
                          ),

                          const SizedBox(width: IAMSizes.spaceBtwItems),

                          Text(
                            'In Stock',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // -- VARIATION DESCRIPTION
              const IAMProductTitleText(
                title: 'Selected variation description.',
                smallSize: true,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),

        // -- ATTRIBUTES
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IAMSectionHeading(title: 'Colors', showActionButton: false,),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            Wrap(
              spacing: 10,
              children: [
                IAMChoiceChip(text: 'Green', selected: true, onSelected: (value){},),
                IAMChoiceChip(text: 'Pink', selected: false, onSelected: (value){},),
                IAMChoiceChip(text: 'Purple', selected: false, onSelected: (value){},),
              ],
            )
          ],
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IAMSectionHeading(title: 'Size', showActionButton: false,),
            SizedBox(height: IAMSizes.spaceBtwItems / 2),
            Wrap(
              spacing: 10,
              children: [
                IAMChoiceChip(text: 'Small', selected: true, onSelected: (value){},),
                IAMChoiceChip(text: 'Medium', selected: false, onSelected: (value){},),
                IAMChoiceChip(text: 'Large', selected: false, onSelected: (value){},),
              ],
            )
          ],
        ),
      ],
    );
  }
}
