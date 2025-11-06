import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup.widgets/signup.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMLoginForm extends StatelessWidget {
  const IAMLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: IAMSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            //email
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: IAMTexts.email,
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwInputFields),
            //password
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                labelText: IAMTexts.password,
                suffixIcon: Icon(Iconsax.eye_slash),
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwInputFields / 2),

            // Remember me and forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //remeber me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(IAMTexts.rememberMe),
                  ],
                ),

                //forgot password
                TextButton(
                  onPressed: () {},
                  child: const Text(IAMTexts.forgetPassword),
                ),
              ],
            ),
            const SizedBox(height: IAMSizes.spaceBtwSections),

            //Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(IAMTexts.signIn),
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),

            //Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: Text(IAMTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
