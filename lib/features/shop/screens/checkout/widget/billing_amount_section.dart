import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMBillingAmountSection extends StatelessWidget {
  const IAMBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        
        // -- SUBTOTAL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium,),
            Text('₱1,000.00', style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),

        // -- SHIPPING FEE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium,),
            Text('₱150.00', style: Theme.of(context).textTheme.labelLarge,),
          ],
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),

        // -- TAX FEE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax', style: Theme.of(context).textTheme.bodyMedium,),
            Text('₱100.00', style: Theme.of(context).textTheme.labelLarge,),
          ],
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),

        // -- ORDER TOTAL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: Theme.of(context).textTheme.bodyMedium,),
            Text('₱1,250.00', style: Theme.of(context).textTheme.titleMedium,),
          ],
        ),
      ],
    );
  }
}