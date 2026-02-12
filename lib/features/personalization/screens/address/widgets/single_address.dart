import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMSingleAddress extends StatelessWidget {
  const IAMSingleAddress({super.key, required this.selectedAddress});

  final bool selectedAddress;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      width: double.infinity,
      showBorder: true,
      backgroundColor: selectedAddress
          ? IAMColors.primary.withOpacity(0.5)
          : Colors.transparent,
      borderColor: selectedAddress
          ? Colors.transparent
          : dark
          ? IAMColors.darkerGrey
          : IAMColors.grey,
      margin: const EdgeInsets.only(bottom: IAMSizes.spaceBtwItems),
      child: Stack(
        children: [
          Positioned(
            right: 5,
            top: 0,
            child: Icon(
              selectedAddress ? Iconsax.tick_circle5 : null,
              color: selectedAddress
                  ? dark
                        ? IAMColors.light
                        : IAMColors.dark.withOpacity(0.4)
                  : null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Juan Dela Cruz',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: IAMSizes.sm / 2),
              const Text(
                '+63 917 123 4567',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: IAMSizes.sm / 2),
              const Text(
                '123 Mabini St., Brgy. Commonwealth, Quezon City, 1105, Philippines',
                softWrap: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
