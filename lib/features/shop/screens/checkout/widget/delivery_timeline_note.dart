import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMDeliveryTimelineNote extends StatelessWidget {
  const IAMDeliveryTimelineNote({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final titleColor = dark ? IAMColors.white : IAMColors.black;
    final bodyColor = dark ? IAMColors.lightGrey : IAMColors.darkerGrey;
    final accentBg = dark
        ? IAMColors.primary.withValues(alpha: 0.14)
        : IAMColors.primary.withValues(alpha: 0.08);

    return Container(
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
                padding: const EdgeInsets.fromLTRB(
                  IAMSizes.md,
                  IAMSizes.md,
                  IAMSizes.md,
                  IAMSizes.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: IAMColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            color: IAMColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                        Text(
                          'Delivery Timeline',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwItems),
                    _DeliveryNoteLine(
                      icon: Icons.payments_outlined,
                      text:
                          'Delivery charges may vary depending on weight and distance.',
                      textColor: bodyColor,
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                    _DeliveryNoteLine(
                      icon: Icons.location_city_outlined,
                      text:
                          'Metro Manila locations: delivery within 1–2 business days.',
                      textColor: bodyColor,
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                    _DeliveryNoteLine(
                      icon: Icons.public_outlined,
                      text: 'Nationwide delivery: within 3–7 business days.',
                      textColor: bodyColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryNoteLine extends StatelessWidget {
  const _DeliveryNoteLine({
    required this.icon,
    required this.text,
    required this.textColor,
  });

  final IconData icon;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 15,
            color: IAMColors.primary.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems / 2),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
