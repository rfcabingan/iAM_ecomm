import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key, this.initialSearchQuery = ''});

  final String initialSearchQuery;

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  String _selectedSort = 'Name';
  late final TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery.trim();
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  num _effectivePrice(ProductItem product) {
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;
    return isLoggedIn ? product.sellingPrice : product.regularPrice;
  }

  List<ProductItem> _sortedProducts(List<ProductItem> source) {
    final list = List<ProductItem>.from(source);

    switch (_selectedSort) {
      case 'Higher Price':
        list.sort((a, b) => _effectivePrice(b).compareTo(_effectivePrice(a)));
        break;
      case 'Lower Price':
        list.sort((a, b) => _effectivePrice(a).compareTo(_effectivePrice(b)));
        break;
      /*case 'Sale':
        list.sort((a, b) {
          final aOnSale = a.memberPrice > 0 && a.memberPrice < a.regularPrice;
          final bOnSale = b.memberPrice > 0 && b.memberPrice < b.regularPrice;
          if (aOnSale != bOnSale) return bOnSale ? 1 : -1;
          return a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
        });
        break;
      case 'Newest':
        return list.reversed.toList();
      case 'Popularity':
        list.sort((a, b) {
          if (a.isPopular != b.isPopular) return b.isPopular ? 1 : -1;
          return a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
        });
        break;*/
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

  List<ProductItem> _filteredProducts(List<ProductItem> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((product) {
      return product.productName.toLowerCase().contains(query) ||
          product.productCode.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query) ||
          product.shortDesc.toLowerCase().contains(query);
    }).toList();
  }

  List<String> _productSuggestions(List<ProductItem> products) {
    final seen = <String>{};
    final suggestions = <String>[];
    for (final product in products) {
      final name = product.productName.trim();
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
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(_searchQuery.isEmpty ? 'All Products' : 'Search Results'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                final controller = Get.find<HomeController>();
                return IAMSearchBar(
                  text: 'Search products',
                  controller: _searchController,
                  suggestions: _productSuggestions(controller.products),
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
                          'Sale',
                          'Newest',
                          'Popularity',
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
                final controller = Get.find<HomeController>();
                if (controller.productsLoading.value) {
                  return const IAMProductGridSkeleton(itemCount: 6);
                }
                if (controller.productsError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      controller.productsError.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = _sortedProducts(
                  _filteredProducts(controller.products),
                );
                if (list.isEmpty) {
                  final message = _searchQuery.isEmpty
                      ? 'No products available'
                      : 'No products found for "$_searchQuery"';
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
