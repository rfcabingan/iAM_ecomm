import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/enums.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMBrandCard extends StatelessWidget {
  const IAMBrandCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.sm),
        showBorder: true,
        backgroundColor: Colors.transparent,
        child: Row(
          children: [
            //Category Icons
            Flexible(
              child: IAMCircularImage(
                isNetworkImage: false,
                image: IAMImages.amazingBarley,
                backgroundColor: Colors.transparent,
                overlayColor: IAMHelperFunctions.isDarkMode(context)
                    ? IAMColors.white
                    : IAMColors.black,
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems / 2),

            // Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IAMBrandTitleWithVerifiedIcon(
                    title: 'Barley',
                    brandTextSize: TextSizes.large,
                  ),
                  Text(
                    '3 products',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
