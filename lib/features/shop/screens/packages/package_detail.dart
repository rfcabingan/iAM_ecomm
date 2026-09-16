import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/features/shop/screens/packages/member_enrollment_form.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/package_option.dart';
import 'package:readmore/readmore.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key, required this.package});

  final PackageOption package;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  PackageSelectionOption? selectedSelectionOption;

  @override
  void initState() {
    super.initState();
    // Select first option by default
    if (widget.package.selectionOptions.isNotEmpty) {
      selectedSelectionOption = widget.package.selectionOptions.first;
    }
  }

  Future<void> _checkoutPackage(BuildContext context) async {
    if (selectedSelectionOption == null) {
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
      selectedOption: selectedSelectionOption!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final package = widget.package;

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(package.name),
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
                          image: AssetImage(package.image),
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
                            package.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: IAMSizes.sm),
                          Text(
                            'Starting from ₱${package.price.toStringAsFixed(2)}',
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
                package.description,
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
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: dark ? IAMColors.darkGrey : Colors.grey),
                  borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PackageSelectionOption>(
                    value: selectedSelectionOption,
                    isExpanded: true,
                    hint: const Text('Select an option'),
                    items: package.selectionOptions.map((option) {
                      return DropdownMenuItem<PackageSelectionOption>(
                        value: option,
                        child: Text('${option.name} - ₱${option.price.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSelectionOption = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // Products Table
              if (selectedSelectionOption != null) ...[
                const IAMSectionHeading(
                  title: 'Included Products',
                  showActionButton: false,
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),
                
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
                      ...selectedSelectionOption!.products.map((product) {
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
                                child: Text(product.productName),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${product.quantity}x'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
              ],

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSelectionOption != null
                      ? () => _checkoutPackage(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                  ),
                  child: Text(
                    selectedSelectionOption != null
                        ? 'Checkout ${selectedSelectionOption!.name}'
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