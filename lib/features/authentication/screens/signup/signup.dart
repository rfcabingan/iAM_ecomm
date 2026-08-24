import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/layouts/web_constrained.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/signup.form.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/helpers/referral_deep_link_service.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key, this.initialReferralId});

  final String? initialReferralId;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final wideWeb = kIsWeb && IAMBreakpoints.isDesktop(context);

    final formBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          IAMTexts.signupTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: IAMSizes.spaceBtwSections),
        IAMSignupForm(initialReferralId: initialReferralId),
        const SizedBox(height: IAMSizes.spaceBtwSections),
        _SignupMemberLoginPrompt(dark: dark),
        const SizedBox(height: IAMSizes.spaceBtwSections),
      ],
    );

    return Scaffold(
      backgroundColor: wideWeb
          ? (dark ? IAMColors.dark : const Color(0xFFF7F5F0))
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? IAMColors.white : IAMColors.black,
        iconTheme: IconThemeData(
          color: dark ? IAMColors.white : IAMColors.black,
        ),
      ),
      body: IAMWebPageScaffold(
        maxWidth: IAMBreakpoints.formMaxWidth + 80,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: wideWeb
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: dark ? IAMColors.black : IAMColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: IAMColors.primary.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? 0.35 : 0.06,
                          ),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                      child: formBody,
                    ),
                  )
                : formBody,
          ),
        ),
      ),
    );
  }
}

class _SignupMemberLoginPrompt extends StatelessWidget {
  const _SignupMemberLoginPrompt({required this.dark});

  final bool dark;

  Future<void> _goToLogin() async {
    await ReferralDeepLinkService.instance.clearSignupPromptOnly();
    Get.to(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final muted = dark ? IAMColors.lightGrey : IAMColors.textSecondary;
    final surface = dark ? IAMColors.dark : IAMColors.white;
    final borderColor = IAMColors.primary.withValues(alpha: dark ? 0.28 : 0.22);
    final wash = IAMColors.primary.withValues(alpha: dark ? 0.08 : 0.06);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: wash,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(color: borderColor),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: IAMColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: surface.withValues(alpha: dark ? 0.42 : 0.88),
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        child: InkWell(
          onTap: _goToLogin,
          borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: IAMSizes.md,
              vertical: IAMSizes.md + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: IAMColors.primary.withValues(
                      alpha: dark ? 0.16 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    color: IAMColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: IAMSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already a member?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login here',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: IAMColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          decoration: TextDecoration.underline,
                          decorationColor: IAMColors.primary.withValues(
                            alpha: 0.55,
                          ),
                          decorationThickness: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: IAMColors.primary.withValues(alpha: 0.9),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
