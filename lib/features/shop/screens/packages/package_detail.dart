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
    final res = await ApiMiddleware.packages.getOptions(widget.package.packageCode);
    if (mounted) {
      setState(() {
        _loadingOptions = false;
        if (res.success) {
          _options = res.data ?? [];
          // Sort by displayOrder
          _options.sort((a, b) => (a?.displayOrder ?? 0).compareTo(b?.displayOrder ?? 0));
          // Select first option by default
          if (_options.isNotEmpty && _options.first != null) {
            _selectedOption = _options.first;
            _loadOptionItems(_selectedOption!);
          }
        } else {
          _optionsError = 'Unable to load package options. Please try again later.';
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
          _optionItems.sort((a, b) => (a?.displayOrder ?? 0).compareTo(b?.displayOrder ?? 0));
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
    Get.to(() => MemberEnrollmentForm(
      package: widget.package,
      selectedOption: _selectedOption!,
      optionItems: _optionItems,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final package = widget.package;

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(package.packageName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Image and Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dark
                        ? [IAMColors.dark, IAMColors.darkerGrey]
                        : [IAMColors.primary, IAMColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                ),
                child: Row(
                  children: [
                    // Package Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                        image: DecorationImage(
                          image: NetworkImage(package.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: IAMSizes.spaceBtwItems),
                    
                    // Package Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.packageName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: IAMSizes.sm),
                          Text(
                            'Starting from ₱${package.packageAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Package Description
              const IAMSectionHeading(
                title: 'Package Description',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              ReadMoreText(
                package.packageDescription,
                trimLines: 3,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Show more',
                trimExpandedText: ' less',
                moreStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                lessStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Package Options Dropdown
              const IAMSectionHeading(
                title: 'Select Package Option',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: dark ? IAMColors.darkGrey : Colors.grey),
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PackageOptionItem>(
                      value: _selectedOption,
                      isExpanded: true,
                      hint: const Text('Select an option'),
                      items: _options
                          .where((option) => option != null)
                          .map((option) => DropdownMenuItem<PackageOptionItem>(
                                value: option,
                                child: Text('${option!.optionName} - ₱${_getOptionPrice(option).toStringAsFixed(2)}'),
                              ))
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
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Products Table
              if (_selectedOption != null) ...[
                const IAMSectionHeading(
                  title: 'Included Products',
                  showActionButton: false,
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
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? IAMColors.dark : Colors.white,
                      borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                      border: Border.all(color: dark ? IAMColors.darkGrey : Colors.grey),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.all(IAMSizes.md),
                          decoration: BoxDecoration(
                            color: dark ? IAMColors.darkerGrey : Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                              topRight: Radius.circular(IAMSizes.cardRadiusMd),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        
                        // Table Rows
                        ..._optionItems.where((item) => item != null).map((item) {
                          return Container(
                            padding: const EdgeInsets.all(IAMSizes.md),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: dark ? IAMColors.darkGrey : Colors.grey),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(item!.productName),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('${item.qty}x'),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
              ],

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOption != null
                      ? () => _checkoutPackage(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                  ),
                  child: Text(
                    _selectedOption != null
                        ? 'Checkout ${_selectedOption!.optionName}'
                        : 'Select an Option',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
