import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
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
      appBar: IAMAppBar(
        showBackArrow: false,
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
                backgroundColor: IAMColors.primary,
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Title
              Text(
                'Registration Successful!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.sm),
              Text(
                registrationData.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Package Image
              if (packageImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                  child: Image.network(
                    packageImage,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: dark ? IAMColors.dark : Colors.grey[300],
                        child: const Icon(Icons.image, size: 60),
                      );
                    },
                  ),
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
                    const SizedBox(height: IAMSizes.sm),
                    Text('Option: ${registrationData.optionName}'),
                    const Divider(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Order Reference',
                      value: registrationData.orderRefno,
                    ),
                    _DetailRow(
                      label: 'Registration Reference',
                      value: registrationData.registrationRefno,
                    ),
                    const Divider(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Package Amount',
                      value: '₱${registrationData.packageAmount.toStringAsFixed(2)}',
                    ),
                    _DetailRow(
                      label: 'Shipping Amount',
                      value: '₱${registrationData.shippingAmount.toStringAsFixed(2)}',
                    ),
                    if (registrationData.processingFee > 0)
                      _DetailRow(
                        label: 'Processing Fee',
                        value: '₱${registrationData.processingFee.toStringAsFixed(2)}',
                      ),
                    if (registrationData.discountAmount > 0)
                      _DetailRow(
                        label: 'Discount',
                        value: '₱${registrationData.discountAmount.toStringAsFixed(2)}',
                      ),
                    const Divider(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Total Amount',
                      value: '₱${registrationData.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                      color: IAMColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Shipping Info
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.dark : Colors.grey[200]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    _DetailRow(
                      label: 'Shipping Method',
                      value: registrationData.shippingMethod,
                    ),
                    _DetailRow(
                      label: 'Shipping Region',
                      value: registrationData.shippingRegion,
                    ),
                    _DetailRow(
                      label: 'Fulfillment Area',
                      value: registrationData.fulfillmentAreaCode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                  ),
                  child: const Text('Continue'),
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
