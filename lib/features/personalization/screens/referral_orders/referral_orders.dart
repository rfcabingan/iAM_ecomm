import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/personalization/screens/referral_orders/widgets/referral_order_list.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class ReferralOrdersScreen extends StatelessWidget {
  const ReferralOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        title: Text(
          'Referral Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        showBackArrow: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Orders shown here are from buyers who used your referral code.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: IAMColors.primary,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : IAMColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color: IAMColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text('Info', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(IAMSizes.defaultSpace),
        child: ReferralOrderList(),
      ),
    );
  }
}
