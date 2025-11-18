import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMSearchBar extends StatelessWidget {
  const IAMSearchBar({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: IAMSizes.defaultSpace),
        child: Container(
          width: IAMDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.all(IAMSizes.md),
          decoration: BoxDecoration(
            color: showBackground
                ? dark
                      ? IAMColors.dark
                      : IAMColors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: IAMColors.white) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: IAMColors.darkGrey),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Text(text, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
