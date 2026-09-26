import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/member_enrollment_info.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class MemberEnrollmentReviewScreen extends StatelessWidget {
  const MemberEnrollmentReviewScreen({
    super.key,
    required this.package,
    required this.selectedOption,
    required this.memberInfo,
    required this.address,
    required this.paymentMethodName,
    required this.fulfillmentLabel,
    required this.feesData,
    required this.idImageBytes,
    this.idImageFile,
    required this.onEditDetails,
    required this.onEditMemberDetails,
    required this.onProceed,
  });

  final PackageItem package;
  final PackageOptionItem selectedOption;
  final MemberEnrollmentInfo memberInfo;
  final AddressItem address;
  final String paymentMethodName;
  final String fulfillmentLabel;
  final PackageComputeFeesData feesData;
  final Uint8List? idImageBytes;
  final ImageProvider? idImageFile;
  final VoidCallback onEditDetails;
  final VoidCallback onEditMemberDetails;
  final VoidCallback onProceed;

  static String _formatPrice(num value) {
    return NumberFormat('#,##0.00', 'en_PH').format(value);
  }

  static String _formatBirthdate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final packagePrice = selectedOption.price ?? package.packageAmount;

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: const Text('Review order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          IAMSizes.defaultSpace,
          IAMSizes.md,
          IAMSizes.defaultSpace,
          IAMSizes.defaultSpace,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: IAMSizes.md),
                child: Text(
                  'Confirm your details before proceeding.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.grey : IAMColors.textSecondary,
                  ),
                ),
              ),
            ),
            _ReviewHeroCard(
              package: package,
              optionName: selectedOption.optionName,
              priceLabel: '₱${_formatPrice(packagePrice)}',
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.user,
              title: 'Member details',
              onEdit: onEditMemberDetails,
              child: Column(
                children: [
                  _LabeledValue(label: 'Name:', value: memberInfo.fullName),
                  _LabeledValue(label: 'Email:', value: memberInfo.email),
                  _LabeledValue(label: 'Phone:', value: memberInfo.phone),
                  _LabeledValue(
                    label: 'Birthdate:',
                    value: _formatBirthdate(memberInfo.birthdate),
                  ),
                  _LabeledValue(label: 'Gender:', value: memberInfo.gender),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.location,
              title: 'Delivery address',
              onEdit: onEditDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.streetAddress.trim().isNotEmpty)
                    Text(
                      address.streetAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  Text(
                    [
                      address.barangay,
                      address.city,
                    ].where((part) => part.trim().isNotEmpty).join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    [
                      address.province,
                      address.country,
                    ].where((part) => part.trim().isNotEmpty).join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.card,
              title: 'Payment & fulfillment',
              onEdit: onEditDetails,
              child: Column(
                children: [
                  _LabeledValue(
                    label: 'Sponsor ID:',
                    value: memberInfo.sponsorIdno ?? '',
                  ),
                  _LabeledValue(label: 'Payment provider:', value: paymentMethodName),
                  _LabeledValue(label: 'Fulfillment:', value: fulfillmentLabel),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.document,
              title: 'Valid ID',
              onEdit: onEditDetails,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(IAMSizes.borderRadiusMd),
                    child: SizedBox(
                      width: 72,
                      height: 56,
                      child: idImageBytes != null
                          ? Image.memory(idImageBytes!, fit: BoxFit.cover)
                          : idImageFile != null
                          ? Image(image: idImageFile!, fit: BoxFit.cover)
                          : ColoredBox(color: IAMColors.light),
                    ),
                  ),
                  const SizedBox(width: IAMSizes.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: IAMColors.success.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.tick_circle, size: 16, color: IAMColors.success),
                        SizedBox(width: 6),
                        Text(
                          'Uploaded',
                          style: TextStyle(
                            color: IAMColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.tick_circle,
              title: 'Terms accepted',
              onEdit: onEditDetails,
              child: Text(
                'I have read and agree to the Terms and Conditions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems),
            _ReviewSectionCard(
              icon: Iconsax.receipt_1,
              title: 'Order total',
              showEdit: false,
              child: Column(
                children: [
                  _AmountRow(label: 'Package', value: feesData.packageAmount),
                  _AmountRow(label: 'Shipping', value: feesData.shippingAmount),
                  _AmountRow(
                    label: 'Processing fee',
                    value: feesData.processingFee,
                  ),
                  if (feesData.discountAmount != 0)
                    _AmountRow(
                      label: 'Discount',
                      value: feesData.discountAmount,
                    ),
                  const SizedBox(height: IAMSizes.sm),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        IAMFormatter.formatCurrency(feesData.totalAmount.toDouble()),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.spaceBtwSections),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            IAMSizes.defaultSpace,
            IAMSizes.sm,
            IAMSizes.defaultSpace,
            IAMSizes.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                    side: const BorderSide(color: IAMColors.primary),
                    foregroundColor: IAMColors.primary,
                  ),
                  child: const Text('Edit details'),
                ),
              ),
              const SizedBox(width: IAMSizes.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Proceed to Payment',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(width: IAMSizes.xs),
                      Icon(Iconsax.arrow_right_3, size: 16),
                    ],
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

class _ReviewHeroCard extends StatelessWidget {
  const _ReviewHeroCard({
    required this.package,
    required this.optionName,
    required this.priceLabel,
  });

  final PackageItem package;
  final String optionName;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        image: const DecorationImage(
          image: AssetImage(IAMImages.goldBg),
          fit: BoxFit.cover,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(IAMSizes.xs),
            child: ClipOval(
              child: package.imageUrl.isNotEmpty
                  ? IAMRoundedImage(
                      imageUrl: package.imageUrl,
                      width: 64,
                      height: 64,
                      applyImageRadius: true,
                      borderRadius: 32,
                      isNetworkImage: true,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Iconsax.box, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.packageName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  optionName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  priceLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSectionCard extends StatelessWidget {
  const _ReviewSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.onEdit,
    this.showEdit = true,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? IAMColors.darkGrey : IAMColors.borderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: IAMColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: IAMColors.primary),
              ),
              const SizedBox(width: IAMSizes.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (showEdit)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: IAMColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Edit'),
                ),
            ],
          ),
          const SizedBox(height: IAMSizes.sm),
          child,
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? IAMColors.grey : IAMColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? IAMColors.grey : IAMColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            IAMFormatter.formatCurrency(value.toDouble()),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
