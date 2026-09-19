import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/shop/screens/packages/all_packages.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/member_enrollment_info.dart';

class PackageRegistrationScreen extends StatefulWidget {
  const PackageRegistrationScreen({
    super.key,
    required this.package,
    required this.selectedOption,
    required this.memberInfo,
    required this.enrollmentAddress,
    this.optionItems,
    required this.feesData,
  });

  final PackageItem package;
  final PackageOptionItem selectedOption;
  final MemberEnrollmentInfo memberInfo;
  final AddressItem enrollmentAddress;
  final List<PackageOptionItemDetail?>? optionItems;
  final PackageComputeFeesData feesData;

  @override
  State<PackageRegistrationScreen> createState() => _PackageRegistrationScreenState();
}

class _PackageRegistrationScreenState extends State<PackageRegistrationScreen> {
  bool _isRegistering = false;
  String? _errorMessage;

  Future<void> _registerPackage() async {
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    // Format birthdate as ISO date string (YYYY-MM-DD)
    final birthDate = widget.memberInfo.birthdate.toIso8601String().split('T')[0];

    final res = await ApiMiddleware.packages.register(
      firstName: widget.memberInfo.firstName,
      middleName: widget.memberInfo.middleName,
      lastName: widget.memberInfo.lastName,
      country: widget.enrollmentAddress.country,
      province: widget.enrollmentAddress.province,
      city: widget.enrollmentAddress.city,
      barangay: widget.enrollmentAddress.barangay,
      completeAddress: widget.enrollmentAddress.completeAddress,
      email: widget.memberInfo.email,
      mobileNo: widget.memberInfo.phone,
      birthDate: birthDate,
      gender: widget.memberInfo.gender,
      packageCode: widget.package.packageCode,
      optionId: widget.selectedOption.optionId,
      sponsorIdno: widget.memberInfo.sponsorIdno ?? '',
      paymentMethodId: widget.memberInfo.paymentMethodId ?? 1,
      fulfillmentTypeId: widget.memberInfo.fulfillmentTypeId ?? 1,
      areaCode: widget.memberInfo.areaCode,
      termsAccepted: widget.memberInfo.termsAccepted,
      // validId: widget.memberInfo.idImageBase64, // Temporarily disabled for testing
    );

    if (mounted) {
      setState(() {
        _isRegistering = false;
        if (res.success) {
          _showSuccessScreen();
        } else {
          _errorMessage = res.message.isNotEmpty ? res.message : 'Registration failed. Please try again.';
        }
      });
    }
  }

  void _showSuccessScreen() {
    Get.off(() => SuccessScreen(
      image: 'assets/images/animations/sammy-success.png',
      title: 'Registration Submitted!',
      subTitle: 'Your package registration has been submitted successfully. You will be notified once it is processed.',
      onPressed: () => Get.offAll(() => const AllPackages()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: const Text('Package Registration'),
        actions: [
          if (!_isRegistering)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _registerPackage,
              tooltip: 'Retry Registration',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Summary
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.packageName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    Text('Selected Option: ${widget.selectedOption.optionName}'),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Fee Summary
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.md),
                    _FeeRow(
                      label: 'Package Price',
                      value: widget.feesData.packagePrice,
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    _FeeRow(
                      label: 'Shipping Fee',
                      value: widget.feesData.shippingFee,
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    _FeeRow(
                      label: 'Tax',
                      value: widget.feesData.tax,
                    ),
                    const Divider(height: IAMSizes.md),
                    _FeeRow(
                      label: 'Total Amount',
                      value: widget.feesData.totalAmount,
                      isBold: true,
                      color: IAMColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Loading State
              if (_isRegistering)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: IAMSizes.md),
                      Text('Submitting registration...'),
                    ],
                  ),
                ),

              // Error State
              if (_errorMessage != null && !_isRegistering)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: IAMSizes.md),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: IAMSizes.md),
                      ElevatedButton(
                        onPressed: _registerPackage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Retry Registration'),
                      ),
                    ],
                  ),
                ),

              // Registration Info (for debugging/testing)
              if (!_isRegistering && _errorMessage == null)
                IAMRoundedContainer(
                  showBorder: true,
                  padding: const EdgeInsets.all(IAMSizes.md),
                  backgroundColor: dark ? IAMColors.darkGrey : Colors.grey[200]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registration Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      Text('Sponsor ID: ${widget.memberInfo.sponsorIdno}'),
                      Text('Payment Method ID: ${widget.memberInfo.paymentMethodId}'),
                      Text('Fulfillment Type ID: ${widget.memberInfo.fulfillmentTypeId}'),
                      if (widget.memberInfo.areaCode != null)
                        Text('Area Code: ${widget.memberInfo.areaCode}'),
                      Text('Terms Accepted: ${widget.memberInfo.termsAccepted}'),
                      Text('Valid ID: ${widget.memberInfo.idImageBase64 != null ? "Uploaded (base64) - NOT SENT" : "Not uploaded"}'),
                    ],
                  ),
                ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Submit Button
              if (!_isRegistering && _errorMessage == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                    ),
                    child: const Text(
                      'Submit Registration',
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

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final num value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          IAMFormatter.formatCurrency(value.toDouble()),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
