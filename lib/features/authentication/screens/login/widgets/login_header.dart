import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';

class IAMLoginHeader extends StatelessWidget {
  const IAMLoginHeader({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        left: IAMSizes.defaultSpace,
        right: IAMSizes.defaultSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Material(
              elevation: 10,
              shape: const CircleBorder(),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: dark ? Colors.white : const Color(0xFF1A1A1A),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        dark ? IAMImages.lightAppLogo : IAMImages.darkAppLogo,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: IAMSizes.spaceBtwSections),
          Text(
            IAMTexts.loginTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: IAMSizes.sm),
          Text(
            IAMTexts.loginSubTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
