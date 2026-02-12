import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMBillingPaymentSection extends StatelessWidget {
  const IAMBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        IAMSectionHeading(title: 'Payment Method', buttonTitle: 'Change', onPressed: () {},),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),
        Row(
          children: [
            IAMRoundedContainer(
              width: 60,
              height: 35,
              backgroundColor: dark ? IAMColors.light : IAMColors.white,
              padding: const EdgeInsets.all(IAMSizes.sm),
              child: const Image(image: AssetImage(IAMImages.maya), fit: BoxFit.contain),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems / 2),
            Text('Maya', style: Theme.of(context).textTheme.bodyLarge,), 
          ],
        )
      ],
    );
  }
}