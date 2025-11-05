import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Positioned(
      bottom: IAMDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: IAMSizes.defaultSpace,

      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: dark ? IAMColors.light : IAMColors.dark,
          dotHeight: 6,
        ),
      ),
    );
  }
}
