import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Positioned(
      right: IAMSizes.defaultSpace,
      bottom: IAMDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark ? IAMColors.primary : Colors.black,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
