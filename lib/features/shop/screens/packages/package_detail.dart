import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
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
import 'package:readmore/readmore.dart';

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
          // Sort by displayOrder
          _options.sort(
            (a, b) => (a?.displayOrder ?? 0).compareTo(b?.displayOrder ?? 0),
          );
          // Select first option by default
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
          // Sort by displayOrder
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
    // Use option price if available, otherwise use package amount
    return option.price ?? widget.package.packageAmount;
  }

  String _formatPrice(num price) {
    final priceString = price.toStringAsFixed(2);

    return priceString.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
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

    // Navigate to member enrollment form
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
                    image: NetworkImage(IAMImages.goldbgcontainer),
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
                      width: 160,
                      height: 160,
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
                                  fontSize: 20,
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
                                  fontSize: 28,
                                ),
                          ),

                          const SizedBox(height: IAMSizes.xs),

                          // Same price for every option
                          Text(
                            'Same price for every option',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white, fontSize: 13),
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
                'Choose Inclusions',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems),

              // ReadMoreText(
              //   package.packageDescription,
              //   trimLines: 3,
              //   trimMode: TrimMode.Line,
              //   trimCollapsedText: ' Show more',
              //   trimExpandedText: ' less',
              //   moreStyle: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w800,
              //   ),
              //   lessStyle: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w800,
              //   ),
              // ),
              // const SizedBox(height: IAMSizes.spaceBtwSections),

              // Package Options Dropdown
              // const IAMSectionHeading(
              //   title: 'Select Package Option',
              //   showActionButton: false,
              // ),
              // const SizedBox(height: IAMSizes.spaceBtwItems),
              if (_loadingOptions)
                const Center(child: CircularProgressIndicator())
              else if (_optionsError != null)
                Padding(
                  padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                  child: Column(
                    children: [
                      Text(
                        _optionsError!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      ElevatedButton(
                        onPressed: _loadOptions,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (_options.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                  child: Text(
                    'No options available for this package.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IAMSizes.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dark ? IAMColors.darkGrey : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(
                          IAMSizes.cardRadiusMd,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PackageOptionItem>(
                          value: _selectedOption,
                          isExpanded: true,
                          items: _options
                              .where((option) => option != null)
                              .map(
                                (option) => DropdownMenuItem<PackageOptionItem>(
                                  value: option,
                                  child: Text(option!.optionName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedOption = value;
                                _loadOptionItems(value);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    if (_selectedOption != null)
                      Text(
                        '${_options.where((option) => option != null).length} options available - ${_formatPrice(_getOptionPrice(_selectedOption!))} each',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Products Table
              if (_selectedOption != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: IAMSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Included Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.info_outline,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'No options available for this package.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                else if (_optionItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      'No items available for this option.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        IAMSizes.cardRadiusMd,
                      ),
                      side: BorderSide(
                        color: dark ? IAMColors.darkGrey : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: _optionItems.where((item) => item != null).map((
                        item,
                      ) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: IAMSizes.md,
                            vertical: 14,
                          ),
                          minVerticalPadding: 16,
                          leading: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(IAMSizes.md),
                            ),
                            child: _buildProductImage(item!.productCode),
                          ),
                          title: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.qty}x',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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

Widget _buildProductImage(String productCode) {
  //  Add product image here
  return const SizedBox.shrink();
}
