import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMBillingAddressSection extends StatelessWidget {
  const IAMBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IAMSectionHeading(title: 'Shipping Address', buttonTitle: 'Change', onPressed: () {},),
        Text('Juan Dela Cruz', style: Theme.of(context).textTheme.bodyLarge,),

        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey, size: 16,),
            const SizedBox(width: IAMSizes.spaceBtwItems,),
            Text('0911-222-3333', style: Theme.of(context).textTheme.bodyMedium,)
          ],
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),

        Row(
          children: [
            const Icon(Icons.location_history, color: Colors.grey, size: 16,),
            const SizedBox(width: IAMSizes.spaceBtwItems,),
            Expanded(child: Text('123 Pedro St., Greenhills, San Juan City, Metro Manila, Philippines', style: Theme.of(context).textTheme.bodyMedium, softWrap: true,))
          ],
        ),
      ],
    );
  }
}