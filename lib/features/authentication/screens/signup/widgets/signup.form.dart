import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/verify_email.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/termsandconditions.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMSignupForm extends StatelessWidget {
  const IAMSignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: IAMTexts.firstName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: IAMSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: IAMTexts.lastName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),

          //Username
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.username,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Email
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Phone number
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwInputFields),
          //Password
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              labelText: IAMTexts.password,
              prefixIcon: Icon(Iconsax.password_check),
              suffixIcon: Icon(Iconsax.eye_slash),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwSections),
          //Terms and Conditions Checkbox
          const IAMTermsAndConditions(),
          const SizedBox(height: IAMSizes.spaceBtwSections),
          //Sign up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const VerifyEmailScreen()),
              child: const Text(IAMTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
