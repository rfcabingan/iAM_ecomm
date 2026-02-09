import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/authentication/controllers/onboarding_controller.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';

class OnBoardSkip extends StatelessWidget {
  const OnBoardSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: IAMDeviceUtils.getAppBarHeight(),
      right: IAMSizes.defaultSpace,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () => OnboardingController.instance.skipPage(),
        child: const Text('Skip'),
      ),
    );
  }
}
