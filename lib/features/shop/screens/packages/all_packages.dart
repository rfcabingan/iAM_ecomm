import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class AllPackages extends StatefulWidget {
  const AllPackages({super.key, this.initialSearchQuery = ''});

  final String initialSearchQuery;

  @override
  State<AllPackages> createState() => _AllPackagesState();
}

class _AllPackagesState extends State<AllPackages> {
  String _selectedSort = 'Name';
  late final TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery.trim();
    _searchController = TextEditingController(text: _searchQuery);
    
    if (!Get.isRegistered<StoreController>()) {
      Get.put(StoreController());
    }
    
    // Load packages on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<StoreController>();
      controller.fetchProductsByCategory(ProductCategories.iamPackages);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  num _effectivePrice(ProductItem product) {
    return product.sellingPrice > 0
        ? product.sellingPrice
        : product.regularPrice;
  }

  List<ProductItem> _sortedPackages(List<ProductItem> source) {
    final list = List<ProductItem>.from(source);

    switch (_selectedSort) {
      case 'Higher Price':
        list.sort((a, b) => _effectivePrice(b).compareTo(_effectivePrice(a)));
        break;
      case 'Lower Price':
        list.sort((a, b) => _effectivePrice(a).compareTo(_effectivePrice(b)));
        break;
      case 'Name':
      default:
        list.sort(
          (a, b) => a.productName.toLowerCase().compareTo(
            b.productName.toLowerCase(),
          ),
        );
        break;
    }

    return list;
  }

  List<ProductItem> _filteredPackages(List<ProductItem> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((product) {
      return product.productName.toLowerCase().contains(query) ||
          product.productCode.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query) ||
          product.shortDesc.toLowerCase().contains(query);
    }).toList();
  }

  List<String> _packageSuggestions(List<ProductItem> packages) {
    final seen = <String>{};
    final suggestions = <String>[];
    for (final package in packages) {
      final name = package.productName.trim();
      final normalizedName = name.toLowerCase();
      if (name.isEmpty || seen.contains(normalizedName)) continue;
      seen.add(normalizedName);
      suggestions.add(name);
    }
    return suggestions;
  }

  void _setSearchQuery(String value) {
    setState(() => _searchQuery = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(_searchQuery.isEmpty ? 'All Packages' : 'Search Packages'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                final controller = Get.find<StoreController>();
                final packages = controller.productsFor(ProductCategories.iamPackages);
                return IAMSearchBar(
                  text: 'Search packages',
                  controller: _searchController,
                  suggestions: _packageSuggestions(packages),
                  onChanged: _setSearchQuery,
                  onSubmitted: _setSearchQuery,
                  onSuggestionSelected: _setSearchQuery,
                  padding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              DropdownButtonFormField<String>(
                initialValue: _selectedSort,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.sort),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedSort = value;
                  });
                },
                items:
                    [
                          'Name',
                          'Higher Price',
                          'Lower Price',
                        ]
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              Obx(() {
                final controller = Get.find<StoreController>();
                final isLoading = controller.loadingByCategory[ProductCategories.iamPackages] ?? false;
                final error = controller.errorByCategory[ProductCategories.iamPackages];
                
                if (isLoading) {
                  return const IAMProductGridSkeleton(itemCount: 6);
                }
                if (error != null && error.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = _sortedPackages(
                  _filteredPackages(controller.productsFor(ProductCategories.iamPackages)),
                );
                if (list.isEmpty) {
                  final message = _searchQuery.isEmpty
                      ? 'No packages available'
                      : 'No packages found for "$_searchQuery"';
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return IAMGridLayout(
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      IAMProductCardVertical(product: list[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}