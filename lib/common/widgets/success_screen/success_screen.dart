import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/styles/spacing_styles.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: IAMSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              Image(
                image: AssetImage(IAMImages.successRegistration),
                width: IAMHelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // TITLE AND SUBTITLE
              Text(
                IAMTexts.yourAccountCreatedTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              Text(
                IAMTexts.yourAccountCreatedSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              //BUTTONS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: const Text(IAMTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
