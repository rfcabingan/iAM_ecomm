import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMDeliveryBranchSection extends StatelessWidget {
  const IAMDeliveryBranchSection({super.key});

  static const String branchName = 'MAIN OFFICE Branch';

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final titleColor = dark ? IAMColors.white : IAMColors.black;
    final bodyColor = dark ? IAMColors.lightGrey : IAMColors.darkerGrey;
    final accentBg = dark
        ? IAMColors.primary.withValues(alpha: 0.14)
        : IAMColors.primary.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Branch',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accentBg,
            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
            border: Border.all(
              color: IAMColors.primary.withValues(alpha: 0.28),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: IAMColors.primary,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(IAMSizes.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: IAMColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            color: IAMColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fulfilled by',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: bodyColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                branchName,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: titleColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
