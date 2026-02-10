import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(IAMSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Headings
            Text(
              IAMTexts.forgetPasswordTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            Text(
              IAMTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: IAMSizes.spaceBtwSections * 2),

            //Text Fields
            TextFormField(
              decoration: const InputDecoration(
                labelText: IAMTexts.email,
                prefixIcon: Icon(Iconsax.direct_right),
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwSections),

            //Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.off(() => const ResetPassword()),
                child: const Text(IAMTexts.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
