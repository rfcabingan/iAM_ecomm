import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_card.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMBrandShowCase extends StatelessWidget {
  const IAMBrandShowCase({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return IAMRoundedContainer(
      showBorder: true,
      borderColor: IAMColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(IAMSizes.md),
      margin: const EdgeInsets.only(bottom: IAMSizes.spaceBtwItems),

      child: Column(
        children: [
          //categories with products count
          const IAMBrandCard(showBorder: false),
          const SizedBox(height: IAMSizes.spaceBtwItems),
          //brand top 3 products
          Row(
            children: images
                .map((image) => brandTopProductsImageWidgets(image, context))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget brandTopProductsImageWidgets(String image, context) {
    return Expanded(
      child: IAMRoundedContainer(
        height: 100,
        padding: const EdgeInsets.all(IAMSizes.md),
        margin: const EdgeInsets.only(right: IAMSizes.sm),
        backgroundColor: IAMHelperFunctions.isDarkMode(context)
            ? IAMColors.darkGrey
            : IAMColors.light,
        child: Image(fit: BoxFit.contain, image: AssetImage(image)),
      ),
    );
  }
}
