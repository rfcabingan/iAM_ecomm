import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMDeliveryTimelineNote extends StatelessWidget {
  const IAMDeliveryTimelineNote({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final titleColor = dark ? IAMColors.white : IAMColors.black;
    final bodyColor = dark ? IAMColors.lightGrey : IAMColors.textSecondary;
    final dividerColor = dark
        ? IAMColors.white.withValues(alpha: 0.12)
        : IAMColors.grey;
    final cardColor = dark
        ? IAMColors.primary.withValues(alpha: 0.10)
        : const Color(0xFFFFFBF3);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
        border: Border.all(
          color: IAMColors.primary.withValues(alpha: dark ? 0.28 : 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          IAMSizes.md,
          IAMSizes.md,
          IAMSizes.md,
          IAMSizes.sm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: IAMColors.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Iconsax.document_text,
                        color: IAMColors.primary,
                        size: 18,
                      ),
                      Positioned(
                        right: 6,
                        bottom: 7,
                        child: Icon(
                          Iconsax.truck,
                          color: IAMColors.primary,
                          size: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: IAMSizes.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery information',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Delivery fees and estimated delivery times.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bodyColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                /*Icon(
                  Icons.chevron_right_rounded,
                  color: bodyColor,
                  size: 22,
                ),*/
              ],
            ),
            const SizedBox(height: IAMSizes.md),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: _DeliveryInfoColumn(
                      icon: Iconsax.wallet_3,
                      title: 'Delivery charges',
                      description:
                          'may vary depending on weight and distance.',
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: dividerColor,
                  ),
                  const Expanded(
                    child: _DeliveryInfoColumn(
                      icon: Iconsax.location,
                      title: 'Metro Manila',
                      description: 'delivery within 1–2 business days.',
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: dividerColor,
                  ),
                  const Expanded(
                    child: _DeliveryInfoColumn(
                      icon: Iconsax.global,
                      title: 'Nationwide',
                      description: 'delivery within 3–7 business days.',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: IAMSizes.sm + 2),
              child: Divider(height: 1, color: dividerColor),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Iconsax.calendar_1,
                    size: 16,
                    color: IAMColors.primary,
                  ),
                ),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: Text(
                    'Delivery schedules may vary during holidays or severe weather conditions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: bodyColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryInfoColumn extends StatelessWidget {
  const _DeliveryInfoColumn({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final titleColor = dark ? IAMColors.white : IAMColors.black;
    final bodyColor = dark ? IAMColors.lightGrey : IAMColors.textSecondary;

    return Column(
      children: [
        Icon(icon, size: 22, color: IAMColors.primary),
        const SizedBox(height: IAMSizes.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: titleColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: bodyColor,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
