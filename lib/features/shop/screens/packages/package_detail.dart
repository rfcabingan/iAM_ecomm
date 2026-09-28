import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/features/shop/screens/packages/member_enrollment_form.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key, required this.package});

  final PackageItem package;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  List<PackageOptionItem?> _options = [];
  List<PackageOptionItemDetail?> _optionItems = [];
  PackageOptionItem? _selectedOption;
  bool _loadingOptions = false;
  bool _loadingItems = false;
  String? _optionsError;
  String? _itemsError;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  String _formatPrice(num price) {
    final priceString = price.toStringAsFixed(2);
    return priceString.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Future<void> _loadOptions() async {
    setState(() => _loadingOptions = true);
    final res = await ApiMiddleware.packages.getOptions(
      widget.package.packageCode,
    );
    if (mounted) {
      setState(() {
        _loadingOptions = false;
        if (res.success) {
          _options = res.data ?? [];
          _options.sort(
            (a, b) => (a?.displayOrder ?? 0).compareTo(b?.displayOrder ?? 0),
          );
          if (_options.isNotEmpty && _options.first != null) {
            _selectedOption = _options.first;
            _loadOptionItems(_selectedOption!);
          }
        } else {
          _optionsError =
              'Unable to load package options. Please try again later.';
        }
      });
    }
  }

  Future<void> _loadOptionItems(PackageOptionItem option) async {
    setState(() => _loadingItems = true);
    final res = await ApiMiddleware.packages.getOptionItems(
      packageCode: widget.package.packageCode,
      optionId: option.optionId,
    );
    if (mounted) {
      setState(() {
        _loadingItems = false;
        if (res.success) {
          _optionItems = res.data ?? [];
          _optionItems.sort(
            (a, b) => (a?.displayOrder ?? 0).compareTo(b?.displayOrder ?? 0),
          );
        } else {
          _itemsError = 'Unable to load package items. Please try again later.';
        }
      });
    }
  }

  num _getOptionPrice(PackageOptionItem option) {
    return option.price ?? widget.package.packageAmount;
  }

  Future<void> _checkoutPackage(BuildContext context) async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a package option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    if (!isLoggedIn) {
      if (!context.mounted) return;
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Have an account?'),
          content: const Text(
            'Have an account? Login now.\nNew to IAM? Sign-up here.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Get.to(() => const LoginScreen());
              },
              child: const Text('Login now'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Get.to(() => const SignupScreen());
              },
              child: const Text('Signup here'),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;
    Get.to(
      () => MemberEnrollmentForm(
        package: widget.package,
        selectedOption: _selectedOption!,
        optionItems: _optionItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final package = widget.package;

    return Scaffold(
      appBar: IAMAppBar(showBackArrow: true, title: Text(package.packageName)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Image and Info
              Container(
                width: double.infinity,
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
                      ).withOpacity(0.45),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Package Image
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          IAMSizes.cardRadiusMd,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(package.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: IAMSizes.sm),

                    // Package Info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Package Name
                          Text(
                            package.packageName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  height: 1.1,
                                ),
                          ),

                          const SizedBox(height: IAMSizes.md),

                          // Package Price
                          Text(
                            '₱${_formatPrice(package.packageAmount)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                          ),

                          const SizedBox(height: IAMSizes.xs),

                          // Same price for every option
                          Text(
                            'Same price for every option',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Package Description
              Text(
                'Choose inclusions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems),

              // Package Options Dropdown
              if (_loadingOptions)
                const Center(child: CircularProgressIndicator())
              else if (_optionsError != null)
                _RetryMessage(message: _optionsError!, onRetry: _loadOptions)
              else if (_options.isEmpty)
                Text(
                  'No options available for this package.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else ...[
                _OptionsDropdown(
                  dark: dark,
                  options: _options.whereType<PackageOptionItem>().toList(),
                  selected: _selectedOption,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedOption = value;
                      _itemsError = null;
                    });
                    _loadOptionItems(value);
                  },
                ),
                const SizedBox(height: IAMSizes.sm),
                Text(
                  '${_options.whereType<PackageOptionItem>().length} options available · ₱${_formatPrice(_selectedOption != null ? _getOptionPrice(_selectedOption!) : widget.package.packageAmount)} each',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.grey : IAMColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Products Table
              if (_selectedOption != null) ...[
                Row(
                  children: [
                    Text(
                      'Included products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: IAMSizes.xs),
                    Tooltip(
                      message: 'Items update when you change options.',
                      child: Icon(
                        Iconsax.info_circle,
                        size: IAMSizes.iconSm,
                        color: dark ? IAMColors.grey : IAMColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  'Items update when you change options.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.grey : IAMColors.textSecondary,
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),
                if (_loadingItems)
                  const Center(child: CircularProgressIndicator())
                else if (_itemsError != null)
                  Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Column(
                      children: [
                        Text(
                          _itemsError!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: IAMSizes.sm),
                        ElevatedButton(
                          onPressed: () => _loadOptionItems(_selectedOption!),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                else if (_optionItems
                    .whereType<PackageOptionItemDetail>()
                    .isEmpty)
                  Text(
                    'No items available for this option.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Column(
                    children: _optionItems
                        .whereType<PackageOptionItemDetail>()
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: IAMSizes.sm),
                            child: _IncludedProductCard(
                              dark: dark,
                              name: item.productName,
                              qty: item.qty,
                              imageUrl: item.imageUrl,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
              ],
            ],
          ),
        ),
      ),

      // Fixed package price and registration button
      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: dark ? IAMColors.darkGrey : Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              IAMSizes.defaultSpace,
              IAMSizes.md,
              IAMSizes.defaultSpace,
              IAMSizes.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: IAMSizes.sm),
                        Text(
                          'Package Price:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      _selectedOption != null
                          ? _formatPrice(_getOptionPrice(_selectedOption!))
                          : _formatPrice(widget.package.packageAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: IAMSizes.md),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        spreadRadius: 0,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 2 * 24,
                    child: ElevatedButton(
                      onPressed: _selectedOption != null
                          ? () => _checkoutPackage(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IAMColors.primary,
                        disabledBackgroundColor: Colors.grey,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Continue to Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IAMSizes.defaultSpace),
      child: Column(
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: IAMSizes.sm),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _OptionsDropdown extends StatelessWidget {
  const _OptionsDropdown({
    required this.dark,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final bool dark;
  final List<PackageOptionItem> options;
  final PackageOptionItem? selected;
  final ValueChanged<PackageOptionItem?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        border: Border.all(
          color: dark ? IAMColors.darkGrey : IAMColors.borderPrimary,
        ),
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PackageOptionItem>(
          value: selected,
          isExpanded: true,
          hint: const Text('Select an option'),
          icon: const Icon(Iconsax.arrow_down_1, size: 18),
          items: options
              .map(
                (option) => DropdownMenuItem<PackageOptionItem>(
                  value: option,
                  child: Text(
                    option.optionName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _IncludedProductCard extends StatelessWidget {
  const _IncludedProductCard({
    required this.dark,
    required this.name,
    required this.qty,
    required this.imageUrl,
  });

  final bool dark;
  final String name;
  final int qty;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.sm),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? IAMColors.darkGrey : IAMColors.borderPrimary,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: dark ? IAMColors.darkerGrey : IAMColors.light,
              borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Iconsax.box,
                          color: dark ? IAMColors.grey : IAMColors.darkGrey,
                        );
                      },
                    ),
                  )
                : Icon(
                    Iconsax.box,
                    color: dark ? IAMColors.grey : IAMColors.darkGrey,
                  ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: IAMSizes.sm),
          Column(
            children: [
              Text(
                'Qty',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: dark ? IAMColors.grey : IAMColors.textSecondary,
                ),
              ),
              Text(
                '${qty}x',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(width: IAMSizes.sm),
        ],
      ),
    );
  }
}
