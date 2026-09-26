import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/features/shop/controllers/product_cache_controller.dart';
import 'package:iam_ecomm/features/shop/screens/packages/member_enrollment_form.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';

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
  Worker? _productsWorker;

  ProductCacheController get _productCache =>
      Get.isRegistered<ProductCacheController>()
      ? ProductCacheController.instance
      : Get.put(ProductCacheController(), permanent: true);

  static String _formatPrice(num value) {
    return NumberFormat('#,##0.00', 'en_PH').format(value);
  }

  @override
  void initState() {
    super.initState();
    _productsWorker = ever(_productCache.productsVersion, (_) {
      if (mounted) setState(() {});
    });
    _loadOptions();
    _productCache.ensureProducts();
  }

  @override
  void dispose() {
    _productsWorker?.dispose();
    super.dispose();
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

  num get _displayedPrice {
    final option = _selectedOption;
    if (option == null) return widget.package.packageAmount;
    return _getOptionPrice(option);
  }

  bool get _samePriceForEveryOption {
    final prices = _options
        .whereType<PackageOptionItem>()
        .map(_getOptionPrice)
        .toSet();
    return prices.length <= 1;
  }

  String _imageUrlFor(PackageOptionItemDetail item) {
    if (item.imageUrl.isNotEmpty) return item.imageUrl;
    return _productCache.productByCode(item.productCode)?.imageUrl ?? '';
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
          padding: const EdgeInsets.fromLTRB(
            IAMSizes.defaultSpace,
            IAMSizes.defaultSpace,
            IAMSizes.defaultSpace,
            IAMSizes.defaultSpace * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PackageHeroCard(
                package: package,
                price: _displayedPrice,
                samePriceForEveryOption: _samePriceForEveryOption,
                formatPrice: _formatPrice,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              Text(
                'Choose inclusions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
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
                  '${_options.whereType<PackageOptionItem>().length} options available · ₱${_formatPrice(_displayedPrice)} each',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? IAMColors.grey : IAMColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: IAMSizes.spaceBtwSections),
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
                  _RetryMessage(
                    message: _itemsError!,
                    onRetry: () => _loadOptionItems(_selectedOption!),
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
                              imageUrl: _imageUrlFor(item),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PackageCheckoutBar(
        dark: dark,
        priceLabel: '₱${_formatPrice(_displayedPrice)}',
        enabled: _selectedOption != null,
        onContinue: () => _checkoutPackage(context),
      ),
    );
  }
}

class _PackageHeroCard extends StatelessWidget {
  const _PackageHeroCard({
    required this.package,
    required this.price,
    required this.samePriceForEveryOption,
    required this.formatPrice,
  });

  final PackageItem package;
  final num price;
  final bool samePriceForEveryOption;
  final String Function(num) formatPrice;

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
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(IAMSizes.sm),
            child: ClipOval(
              child: package.imageUrl.isNotEmpty
                  ? IAMRoundedImage(
                      imageUrl: package.imageUrl,
                      width: 76,
                      height: 76,
                      applyImageRadius: true,
                      borderRadius: 38,
                      isNetworkImage: true,
                      fit: BoxFit.cover,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    )
                  : const Icon(Iconsax.box, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(width: IAMSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.packageName.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  '₱${formatPrice(price)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (samePriceForEveryOption) ...[
                  const SizedBox(height: IAMSizes.xs),
                  Text(
                    'Same price for every option',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                ? IAMRoundedImage(
                    imageUrl: imageUrl,
                    width: 72,
                    height: 72,
                    applyImageRadius: true,
                    isNetworkImage: true,
                    fit: BoxFit.cover,
                    backgroundColor: dark
                        ? IAMColors.darkerGrey
                        : IAMColors.light,
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

class _PackageCheckoutBar extends StatelessWidget {
  const _PackageCheckoutBar({
    required this.dark,
    required this.priceLabel,
    required this.enabled,
    required this.onContinue,
  });

  final bool dark;
  final String priceLabel;
  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        IAMSizes.defaultSpace,
        IAMSizes.md,
        IAMSizes.defaultSpace,
        IAMSizes.md,
      ),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        border: Border(
          top: BorderSide(
            color: dark ? IAMColors.darkGrey : IAMColors.borderSecondary,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Package price',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? IAMColors.grey : IAMColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  priceLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: IAMSizes.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: IAMColors.primary,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Registration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: IAMSizes.sm),
                    Icon(Iconsax.arrow_right_3, size: 18),
                  ],
                ),
              ),
            ),
          ],
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
