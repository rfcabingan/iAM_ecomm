import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_appbar.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_categories.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/features/screens/home/widgets/promo_slider.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    final homeControllerWasRegistered = Get.isRegistered<HomeController>();
    if (!homeControllerWasRegistered) {
      Get.put(HomeController());
    }
    _controller = Get.find<HomeController>();
    if (homeControllerWasRegistered) {
      unawaited(_controller.fetchProducts(force: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    void openSearchResults(String query) {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) return;
      Get.to(() => AllProducts(initialSearchQuery: trimmedQuery));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMPrimaryHeaderContainer(
              child: Column(
                children: [
                  //Appbar
                  const IAMHomeAppBar(),
                  SizedBox(height: IAMSizes.spaceBtwSections),

                  //Searchbar
                  Obx(
                    () => IAMSearchBar(
                      text: 'Search in Store',
                      suggestions: _controller.products
                          .map((product) => product.productName)
                          .where((name) => name.trim().isNotEmpty)
                          .toList(),
                      onSubmitted: openSearchResults,
                      onSuggestionSelected: openSearchResults,
                    ),
                  ),
                  SizedBox(height: IAMSizes.spaceBtwSections),

                  //Categories
                  Padding(
                    padding: EdgeInsets.only(left: IAMSizes.defaultSpace),
                    child: Column(
                      children: [
                        //heading
                        IAMSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: IAMSizes.spaceBtwItems),

                        //Categories
                        IAMHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),
            //Body
            Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  IAMPromoSlider(
                    banners: [
                      IAMImages.banner1,
                      IAMImages.banner2,
                      IAMImages.banner3,
                    ],
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  //Heading
                  IAMSectionHeading(
                    title: 'Popular Products',
                    onPressed: () => Get.to(() => const AllProducts()),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  Obx(() {
                    final productsVersion = _controller.productsVersion.value;

                    if (_controller.productsLoading.value) {
                      return const IAMProductGridSkeleton(itemCount: 4);
                    }
                    if (_controller.productsError.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                        child: Text(
                          _controller.productsError.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    final list = _controller.popularProducts;
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                        child: Text(
                          'No popular products available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return IAMGridLayout(
                      key: ValueKey('popular-products-$productsVersion'),
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final product = list[index];
                        return IAMProductCardVertical(
                          key: ValueKey(
                            '${product.productCode}-${product.regularPrice}-${product.sellingPrice}-$productsVersion',
                          ),
                          product: product,
                        );
                      },
                    );
                  }),
                ],
              ),

              // Popular products
            ),
          ],
        ),
      ),
    );
  }
}
