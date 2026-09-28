import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/packages/package_registration.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/member_enrollment_info.dart';

class PackageFeeComputationScreen extends StatefulWidget {
  const PackageFeeComputationScreen({
    super.key,
    required this.package,
    required this.selectedOption,
    required this.memberInfo,
    required this.enrollmentAddress,
    this.optionItems,
  });

  final PackageItem package;
  final PackageOptionItem selectedOption;
  final MemberEnrollmentInfo memberInfo;
  final AddressItem enrollmentAddress;
  final List<PackageOptionItemDetail?>? optionItems;

  @override
  State<PackageFeeComputationScreen> createState() => _PackageFeeComputationScreenState();
}

class _PackageFeeComputationScreenState extends State<PackageFeeComputationScreen> {
  bool _isComputing = false;
  String? _errorMessage;
  PackageComputeFeesData? _feesData;

  @override
  void initState() {
    super.initState();
    _computeFees();
  }

  Future<void> _computeFees() async {
    setState(() {
      _isComputing = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiMiddleware.packages.computeFees(
        packageCode: widget.package.packageCode,
        optionId: widget.selectedOption.optionId,
        paymentMethodId: widget.memberInfo.paymentMethodId ?? 1,
        fulfillmentTypeId: widget.memberInfo.fulfillmentTypeId ?? 1,
        country: widget.enrollmentAddress.country,
        province: widget.enrollmentAddress.province,
        city: widget.enrollmentAddress.city,
        barangay: widget.enrollmentAddress.barangay,
        areaCode: widget.memberInfo.areaCode,
      );

      if (mounted) {
        setState(() {
          _isComputing = false;
          if (res.success) {
            _feesData = res.data;
          } else {
            _errorMessage = res.message.isNotEmpty ? res.message : 'Failed to compute fees. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isComputing = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      }
    }
  }

  void _proceedToRegistration() {
    if (_feesData == null) return;

    Get.to(() => PackageRegistrationScreen(
      package: widget.package,
      selectedOption: widget.selectedOption,
      memberInfo: widget.memberInfo,
      enrollmentAddress: widget.enrollmentAddress,
      optionItems: widget.optionItems,
      feesData: _feesData!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: const Text('Fee Computation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Summary
              SizedBox(
                width: double.infinity,
                child: IAMRoundedContainer(
                  showBorder: true,
                  padding: const EdgeInsets.all(IAMSizes.md),
                  backgroundColor: dark ? IAMColors.black : IAMColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _feesData?.packageName ?? widget.package.packageName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      Text('Selected Option: ${_feesData?.optionName ?? widget.selectedOption.optionName}'),
                      const SizedBox(height: IAMSizes.sm),
                      Text(
                        'Package Amount: ₱${(_feesData?.packageAmount ?? (widget.selectedOption.price ?? widget.package.packageAmount)).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: IAMColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Loading State
              if (_isComputing)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: IAMSizes.md),
                      Text('Computing fees...'),
                    ],
                  ),
                ),

              // Error State
              if (_errorMessage != null && !_isComputing)
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
                        onPressed: _computeFees,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Fee Breakdown
              if (_feesData != null && !_isComputing)
                IAMRoundedContainer(
                  showBorder: true,
                  padding: const EdgeInsets.all(IAMSizes.md),
                  backgroundColor: dark ? IAMColors.black : IAMColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fee Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.md),
                      _FeeRow(
                        label: 'Package Amount',
                        value: _feesData!.packageAmount,
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(
                        label: 'Shipping Amount',
                        value: _feesData!.shippingAmount,
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(
                        label: 'Processing Fee',
                        value: _feesData!.processingFee,
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(
                        label: 'Discount Amount',
                        value: _feesData!.discountAmount,
                      ),
                      const Divider(height: IAMSizes.md),
                      _FeeRow(
                        label: 'Total Amount',
                        value: _feesData!.totalAmount,
                        isBold: true,
                        color: IAMColors.primary,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Action Buttons
              if (_feesData != null && !_isComputing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: IAMSizes.spaceBtwItems),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _proceedToRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: IAMColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Proceed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
