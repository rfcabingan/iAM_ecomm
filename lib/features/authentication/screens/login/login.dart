import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iam_ecomm/common/styles/spacing_styles.dart';
import 'package:iam_ecomm/common/widgets/login_signup/form_divider.dart';
import 'package:iam_ecomm/common/widgets/login_signup/social_buttons.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_form.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_header.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: IAMSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              //Logo
              IAMLoginHeader(dark: dark),

              //Form
              IAMLoginForm(),

              //Divider
              IAMFormDivider(dividerText: IAMTexts.orSignInWith.capitalize!),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              //Footer
              IAMSocialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
