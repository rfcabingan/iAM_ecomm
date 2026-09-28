import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class PackageRegistrationSuccessScreen extends StatelessWidget {
  const PackageRegistrationSuccessScreen({
    super.key,
    required this.registrationData,
    required this.packageImage,
  });

  final PackageRegistrationData registrationData;
  final String packageImage;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: IAMColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final labelColor = dark ? IAMColors.lightGrey : IAMColors.textSecondary;
    final valueColor = dark ? IAMColors.white : IAMColors.black;
    final headingColor = dark ? IAMColors.white : const Color(0xFF1A2744);

    return Scaffold(
      backgroundColor: dark ? IAMColors.dark : IAMColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: dark ? IAMColors.dark : IAMColors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed('/'),
            icon: Icon(Icons.close, color: headingColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: IAMSizes.defaultSpace),
          child: Column(
            children: [
              _SuccessIcon(),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Text(
                'Registration submitted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: headingColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.sm),
              Text(
                'Your ${registrationData.packageName} registration has been created.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  height: 1.4,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.md,
                  vertical: IAMSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: dark
                      ? IAMColors.primary.withValues(alpha: 0.15)
                      : IAMColors.accent,
                  borderRadius: BorderRadius.circular(IAMSizes.buttonRadius * 3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: dark ? IAMColors.primary : const Color(0xFF9A7B2E),
                    ),
                    const SizedBox(width: IAMSizes.xs),
                    Text(
                      'Payment pending',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: dark
                            ? IAMColors.primary
                            : const Color(0xFF9A7B2E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.sm),
              Text(
                'Complete your PayMaya payment to process this order.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  height: 1.4,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              _PackageBanner(
                packageImage: packageImage,
                packageName: registrationData.packageName,
                optionName: registrationData.optionName,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Iconsax.document_text,
                      title: 'Reference numbers',
                      titleColor: headingColor,
                    ),
                    const SizedBox(height: IAMSizes.md),
                    _CopyableDetailRow(
                      label: 'Order reference',
                      value: registrationData.orderRefno,
                      labelColor: labelColor,
                      valueColor: valueColor,
                      onCopy: () => _copyToClipboard(
                        context,
                        registrationData.orderRefno,
                        'Order reference',
                      ),
                    ),
                    _CopyableDetailRow(
                      label: 'Registration reference',
                      value: registrationData.registrationRefno,
                      labelColor: labelColor,
                      valueColor: valueColor,
                      onCopy: () => _copyToClipboard(
                        context,
                        registrationData.registrationRefno,
                        'Registration reference',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: IAMSizes.md,
                      ),
                      child: Divider(
                        height: 1,
                        color: dark ? IAMColors.darkerGrey : IAMColors.borderSecondary,
                      ),
                    ),
                    _SectionHeader(
                      icon: Iconsax.card,
                      title: 'Amount breakdown',
                      titleColor: headingColor,
                    ),
                    const SizedBox(height: IAMSizes.md),
                    _DetailRow(
                      label: 'Package',
                      value: _currencyFormat.format(registrationData.packageAmount),
                      labelColor: labelColor,
                      valueColor: valueColor,
                    ),
                    _DetailRow(
                      label: 'Shipping',
                      value: _currencyFormat.format(registrationData.shippingAmount),
                      labelColor: labelColor,
                      valueColor: valueColor,
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    _DetailRow(
                      label: 'Total due',
                      value: _currencyFormat.format(registrationData.totalAmount),
                      labelColor: headingColor,
                      valueColor: IAMColors.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    foregroundColor: IAMColors.white,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(IAMSizes.buttonRadius),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to PayMaya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: IAMSizes.xs),
                      Icon(Iconsax.arrow_right_3, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 96,
        height: 96,
        padding: const EdgeInsets.all(IAMSizes.md),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 221, 171, 57),
              Color.fromARGB(255, 201, 147, 40),
              Color.fromARGB(255, 221, 171, 57),
            ],
            stops: [0.2, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(128, 255, 206, 43),
              blurRadius: 10,
              spreadRadius: 5,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 65,
          color: Colors.white,
          weight: 700,
        ),
      ),
    );
  }
}

class _PackageBanner extends StatelessWidget {
  const _PackageBanner({
    required this.packageImage,
    required this.packageName,
    required this.optionName,
  });

  final String packageImage;
  final String packageName;
  final String optionName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120, // Fixed height to make it smaller
      padding: const EdgeInsets.fromLTRB(
        IAMSizes.md,
        IAMSizes.md,
        IAMSizes.md,
        IAMSizes.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        image: DecorationImage(
          image: const AssetImage(IAMImages.goldBg),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color.fromARGB(
              255,
              209,
              207,
              207,
            ).withValues(alpha: 0.45),
            BlendMode.darken,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Package Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                IAMSizes.cardRadiusMd,
              ),
              image: DecorationImage(
                image: NetworkImage(packageImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: IAMSizes.sm),
          // Package Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: IAMSizes.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package Name
                  Text(
                    packageName,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: IAMSizes.xs),
                  // Option Name
                  Text(
                    optionName,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.titleColor,
  });

  final IconData icon;
  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(IAMSizes.sm),
          decoration: BoxDecoration(
            color: IAMColors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: IAMColors.primary),
        ),
        const SizedBox(width: IAMSizes.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final weight = isBold ? FontWeight.w800 : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: IAMSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: weight,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: weight,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableDetailRow extends StatelessWidget {
  const _CopyableDetailRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    required this.onCopy,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: IAMSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Iconsax.copy),
            iconSize: IAMSizes.iconSm,
            color: IAMColors.primary,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
