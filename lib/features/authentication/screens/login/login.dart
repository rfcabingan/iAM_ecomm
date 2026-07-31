import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login_web.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_form.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_header.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/platform_layout.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Desktop browsers get a dedicated storefront login.
    // Android / iOS keep the original mobile layout unchanged.
    if (IAMPlatformLayout.isWebDesktop(context)) {
      return const LoginWebScreen();
    }

    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() => const NavigationMenu());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              IAMLoginHeader(dark: dark),
              const IAMLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
