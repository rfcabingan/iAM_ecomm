import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/package_card.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/features/shop/screens/packages/all_packages.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCategoryTab extends StatefulWidget {
  const IAMCategoryTab({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<IAMCategoryTab> createState() => _IAMCategoryTabState();
}

class _IAMCategoryTabState extends State<IAMCategoryTab> {
  // Package data from API
  List<PackageItem?> _packages = [];
  bool _loadingPackages = false;
  String? _packagesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<StoreController>();
      if (!controller.loadingByCategory.containsKey(widget.categoryId) &&
          !controller.productsByCategory.containsKey(widget.categoryId)) {
        controller.fetchProductsByCategory(widget.categoryId);
      }
      // Load packages if this is the packages category
      if (widget.categoryId == ProductCategories.iamPackages) {
        _loadPackages();
      }
    });
  }

  Future<void> _loadPackages() async {
    setState(() => _loadingPackages = true);
    final res = await ApiMiddleware.packages.getPackages();
    if (mounted) {
      setState(() {
        _loadingPackages = false;
        if (res.success) {
          _packages = res.data ?? [];
          // Sort by packageId for consistent ordering
          _packages.sort((a, b) => a?.packageId.compareTo(b?.packageId ?? 0) ?? 0);
        } else {
          _packagesError = 'Unable to load packages. Please check your internet connection and try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final categoryId = widget.categoryId;
    final categoryName =
        ProductCategories.names[ProductCategories.ids
            .indexOf(categoryId)
            .clamp(0, ProductCategories.names.length - 1)];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              /*IAMBrandShowCase(
                images: [
                  IAMImages.pibarcap,
                  IAMImages.pibarcho,
                  IAMImages.piacaibr,
                ],
              ),*/
              const SizedBox(height: IAMSizes.spaceBtwItems),
              IAMSectionHeading(
                title: categoryName,
                onPressed: () => categoryId == ProductCategories.iamPackages
                    ? Get.to(() => const AllPackages())
                    : Get.to(() => const AllProducts()),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              // Special handling for packages category (uses regular state, not Obx)
              if (categoryId == ProductCategories.iamPackages)
                Builder(
                  builder: (context) {
                    if (_loadingPackages) {
                      return const IAMProductGridSkeleton(itemCount: 4);
                    }
                    if (_packagesError != null) {
                      return Padding(
                        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                        child: Column(
                          children: [
                            Text(
                              _packagesError!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: IAMSizes.sm),
                            ElevatedButton(
                              onPressed: _loadPackages,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (_packages.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                        child: Text(
                          'No packages available at the moment. Please check back later.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return IAMGridLayout(
                      itemCount: _packages.length,
                      itemBuilder: (_, index) {
                        final package = _packages[index];
                        if (package == null) return const SizedBox.shrink();
                        return IAMPackageCard(package: package);
                      },
                    );
                  },
                ),

              // Regular product categories (uses Obx for controller observables)
              if (categoryId != ProductCategories.iamPackages)
                Obx(() {
                if (controller.loadingByCategory[categoryId] == true) {
                  return const IAMProductGridSkeleton(itemCount: 4);
                }
                final err = controller.errorByCategory[categoryId];
                if (err != null && err.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      err,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = controller.productsFor(categoryId);
                return IAMGridLayout(
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      IAMProductCardVertical(product: list[index]),
                );
              }),
              const SizedBox(height: IAMSizes.spaceBtwSections),
            ],
          ),
        ),
      ],
    );
  }
}
