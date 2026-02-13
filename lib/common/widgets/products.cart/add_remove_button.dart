import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMProductQuantityWithAddRemoveButton extends StatelessWidget {
  const IAMProductQuantityWithAddRemoveButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IAMCircularIcon(
          icon: Iconsax.minus,
          width: 32,
          height: 32,
          size: IAMSizes.md,
          color: IAMHelperFunctions.isDarkMode(context)
              ? IAMColors.white
              : IAMColors.black,
          backgroundColor: IAMHelperFunctions.isDarkMode(context)
              ? IAMColors.darkerGrey
              : IAMColors.light,
        ),
        
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Text('2', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        
        IAMCircularIcon(
          icon: Iconsax.add,
          width: 32,
          height: 32,
          size: IAMSizes.md,
          color: IAMColors.white,
          backgroundColor: IAMColors.primary,
        ),
      ],
    );
  }
}
