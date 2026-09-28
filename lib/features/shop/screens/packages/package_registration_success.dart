import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class PackageRegistrationSuccessScreen extends StatelessWidget {
  const PackageRegistrationSuccessScreen({
    super.key,
    required this.registrationData,
    required this.packageImage,
  });

  final PackageRegistrationData registrationData;
  final String packageImage;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed('/'),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              // Success Icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFD4AF37), // Gold color
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              // Payment Pending Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: IAMSizes.sm),
                  Text(
                    'Payment pending',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.sm),
              Text(
                'Complete your payment via PayMaya',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? Colors.white70 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Package Details
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registrationData.packageName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.xs),
                    Text(
                      registrationData.optionName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const Divider(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Order reference',
                      value: registrationData.orderRefno,
                    ),
                    _DetailRow(
                      label: 'Registration reference',
                      value: registrationData.registrationRefno,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              // Amount Breakdown
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Package',
                      value: '₱${registrationData.packageAmount.toStringAsFixed(2)}',
                    ),
                    _DetailRow(
                      label: 'Shipping',
                      value: '₱${registrationData.shippingAmount.toStringAsFixed(2)}',
                    ),
                    const Divider(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Total due',
                      value: '₱${registrationData.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                      color: IAMColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Continue to PayMaya Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0085CA), // PayMaya blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue to PayMaya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: IAMSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
