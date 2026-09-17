import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/package_card.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_appbar.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_categories.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/features/screens/home/widgets/promo_slider.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/features/shop/screens/packages/all_packages.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/models/image_item.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iam_ecomm/features/screens/home/home_web.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/platform_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  static const String _bannersCacheKey = 'home_banners_cache_v1';
  final IAMLocalStorage _storage = IAMLocalStorage();

  // Package data from API
  List<PackageItem?> _packages = [];
  bool _loadingPackages = false;
  String? _packagesError;

  List<String> _bannerUrls = const [];
  bool _bannersLoading = true;

  @override
  void initState() {
    super.initState();
    final homeControllerWasRegistered = Get.isRegistered<HomeController>();
    if (!homeControllerWasRegistered) {
      Get.put(HomeController());
    }
    _controller = Get.find<HomeController>();
    if (homeControllerWasRegistered) {
      unawaited(_controller.fetchProducts());
    }

    unawaited(_loadBannerUrls());
    unawaited(_loadPackages());
  }

  Future<void> _loadBannerUrls() async {
    try {
      // 1) Load cached banners first to avoid re-calling the API.
      final cached = _storage.readData<List>(_bannersCacheKey);
      final cachedUrls = (cached ?? const []).whereType<String>().toList();
      if (cachedUrls.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _bannerUrls = cachedUrls;
          _bannersLoading = false;
        });
        return;
      }

      // 2) Fetch banners from backend (sort by sortOrder, only visible).
      final ApiResponse<List<ImageItem>> res =
          await ApiMiddleware.images.getImages(imageType: 'Banners');

      if (!mounted) return;
      if (res.success && res.data != null) {
        final banners = res.data!
            .where((img) => img.isVisible)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        final urls = banners.map((img) => img.filePath).toList();

        if (urls.isNotEmpty) {
          await _storage.saveData(_bannersCacheKey, urls);
        }

        setState(() {
          _bannerUrls = urls;
          _bannersLoading = false;
        });
        return;
      }

      setState(() {
        _bannerUrls = const [];
        _bannersLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bannerUrls = const [];
        _bannersLoading = false;
      });
    }
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

  // Get packages to display on home: Jade Package (A011) + 1 random package
  List<PackageItem?> _getDisplayedPackages() {
    final jadePackage = _packages.firstWhere(
      (p) => p?.packageCode == 'A011',
      orElse: () => null,
    );

    final otherPackages = _packages.where((p) => p?.packageCode != 'A011').toList();

    if (jadePackage == null && otherPackages.isEmpty) {
      return [];
    }

    final List<PackageItem?> displayed = [];
    if (jadePackage != null) {
      displayed.add(jadePackage);
    }

    if (otherPackages.isNotEmpty) {
      final random = Random();
      final randomPackage = otherPackages[random.nextInt(otherPackages.length)];
      displayed.add(randomPackage);
    }

    return displayed;
  }

  @override
  Widget build(BuildContext context) {
    void openSearchResults(String query) {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) return;
      Get.to(() => AllProducts(initialSearchQuery: trimmedQuery));
    }

    if (IAMPlatformLayout.isWebDesktop(context)) {
      return HomeWebScreen(
        bannerUrls: _bannerUrls,
        bannersLoading: _bannersLoading,
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMPrimaryHeaderContainer(
              child: Column(
                children: [
                  const IAMHomeAppBar(),
                  SizedBox(height: IAMSizes.spaceBtwSections),
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
                  Padding(
                    padding: EdgeInsets.only(left: IAMSizes.defaultSpace),
                    child: Column(
                      children: [
                        IAMSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        IAMHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  if (_bannersLoading)
                    const AspectRatio(
                      aspectRatio: 725 / 450,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_bannerUrls.isNotEmpty)
                    IAMPromoSlider(banners: _bannerUrls)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
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
                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  // Packages
                  IAMSectionHeading(
                    title: 'Packages',
                    onPressed: () => Get.to(() => const AllPackages()),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  if (_loadingPackages)
                    const IAMProductGridSkeleton(itemCount: 2)
                  else if (_packagesError != null)
                    Padding(
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
                    )
                  else if (_packages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                      child: Text(
                        'No packages available at the moment. Please check back later.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    IAMGridLayout(
                      itemCount: _getDisplayedPackages().length,
                      itemBuilder: (_, index) {
                        final package = _getDisplayedPackages()[index];
                        if (package == null) return const SizedBox.shrink();
                        return IAMPackageCard(package: package);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
