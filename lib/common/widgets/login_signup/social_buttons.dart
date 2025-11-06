import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMSocialButton extends StatelessWidget {
  const IAMSocialButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: IAMColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              width: IAMSizes.iconMd,
              height: IAMSizes.iconMd,
              image: AssetImage(IAMImages.google),
            ),
          ),
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: IAMColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              width: IAMSizes.iconMd,
              height: IAMSizes.iconMd,
              image: AssetImage(IAMImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
