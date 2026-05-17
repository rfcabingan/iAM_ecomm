import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';

class ProductCacheController extends GetxController {
  static ProductCacheController get instance =>
      Get.find<ProductCacheController>();

  final products = <ProductItem>[].obs;
  final productsLoading = false.obs;
  final productsError = ''.obs;
  final productsVersion = 0.obs;

  final productsByCategory = <int, List<ProductItem>>{}.obs;
  final loadingByCategory = <int, bool>{}.obs;
  final errorByCategory = <int, String>{}.obs;

  final featuredProducts = <ProductItem>[].obs;
  final featuredLoading = false.obs;
  final featuredError = ''.obs;

  bool _productsLoaded = false;
  bool _productsAttempted = false;
  int _revision = 0;
  Future<void>? _productsRequest;
  final Map<int, Future<void>> _categoryRequests = {};

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.instance.isLoggedIn, (_) => refreshLoadedProducts());
    }
  }

  List<ProductItem> get popularProducts =>
      products.where((p) => p.isPopular).toList();

  Future<void> ensureProducts() => fetchProducts();

  Future<void> fetchProducts({bool force = false}) async {
    if (!force && (_productsLoaded || _productsAttempted)) return;
    if (_productsRequest != null) return _productsRequest!;

    final request = _fetchProducts(force: force, revision: _revision);
    _productsRequest = request;
    await request;
    if (_productsRequest == request) {
      _productsRequest = null;
    }
  }

  Future<void> _fetchProducts({
    required bool force,
    required int revision,
  }) async {
    productsLoading.value = true;
    productsError.value = '';
    featuredLoading.value = true;
    featuredError.value = '';

    try {
      final res = await ApiMiddleware.products.getProducts();
      if (revision != _revision) return;

      _productsAttempted = true;
      productsLoading.value = false;
      featuredLoading.value = false;

      if (!res.success) {
        productsError.value = res.message;
        featuredError.value = res.message;
        if (force || products.isEmpty) {
          products.clear();
          featuredProducts.clear();
          _productsLoaded = false;
          productsVersion.value++;
        }
        return;
      }

      final list = (res.data ?? const <ProductItem?>[])
          .whereType<ProductItem>()
          .toList();
      products.assignAll(list);
      featuredProducts.assignAll(list.where((p) => p.isFeatured));
      _productsLoaded = true;
      productsVersion.value++;
      await _replaceLoadedCategoryBucketsFromProducts(revision);
    } catch (e) {
      if (revision != _revision) return;
      _productsAttempted = true;
      productsLoading.value = false;
      featuredLoading.value = false;
      productsError.value = 'Network error: $e';
      featuredError.value = 'Network error: $e';
      if (force || products.isEmpty) {
        products.clear();
        featuredProducts.clear();
        _productsLoaded = false;
        productsVersion.value++;
      }
    }
  }

  Future<void> ensureFeaturedProducts() => fetchFeaturedProducts();

  Future<void> fetchFeaturedProducts({bool force = false}) {
    return fetchProducts(force: force);
  }

  Future<void> ensureProductsByCategory(int categoryId) {
    return fetchProductsByCategory(categoryId);
  }

  Future<void> fetchProductsByCategory(
    int categoryId, {
    bool force = false,
  }) async {
    if (!force && productsByCategory.containsKey(categoryId)) return;
    if (!force && _productsLoaded) {
      await _replaceCategoryBucketFromProducts(categoryId, _revision);
      return;
    }
    if (!force && _productsRequest != null) {
      await _productsRequest!;
      if (_productsLoaded) {
        await _replaceCategoryBucketFromProducts(categoryId, _revision);
        return;
      }
    }
    if (_categoryRequests[categoryId] != null) {
      return _categoryRequests[categoryId]!;
    }

    final request = _fetchProductsByCategory(
      categoryId,
      force: force,
      revision: _revision,
    );
    _categoryRequests[categoryId] = request;
    await request;
    if (_categoryRequests[categoryId] == request) {
      _categoryRequests.remove(categoryId);
    }
  }

  Future<void> _fetchProductsByCategory(
    int categoryId, {
    required bool force,
    required int revision,
  }) async {
    loadingByCategory[categoryId] = true;
    errorByCategory[categoryId] = '';
    loadingByCategory.refresh();
    errorByCategory.refresh();

    try {
      final res = await ApiMiddleware.products.getProductsByCategory(
        categoryId,
      );
      if (revision != _revision) return;

      loadingByCategory[categoryId] = false;
      errorByCategory[categoryId] = res.success ? '' : res.message;

      if (res.success) {
        final list = (res.data ?? const <ProductItem?>[])
            .whereType<ProductItem>()
            .toList();
        productsByCategory[categoryId] = await _withExtraProducts(
          categoryId,
          list,
          revision,
        );
      } else if (force || !productsByCategory.containsKey(categoryId)) {
        productsByCategory[categoryId] = [];
      }
    } catch (e) {
      if (revision != _revision) return;
      loadingByCategory[categoryId] = false;
      errorByCategory[categoryId] = 'Network error: $e';
      if (force || !productsByCategory.containsKey(categoryId)) {
        productsByCategory[categoryId] = [];
      }
    } finally {
      loadingByCategory.refresh();
      errorByCategory.refresh();
      productsByCategory.refresh();
    }
  }

  Future<void> refreshLoadedProducts() async {
    final loadedCategoryIds = productsByCategory.keys.toList();
    final shouldReloadProducts = _productsLoaded || products.isNotEmpty;

    _revision++;
    _productsLoaded = false;
    _productsAttempted = false;
    _productsRequest = null;
    _categoryRequests.clear();
    products.clear();
    featuredProducts.clear();
    productsByCategory.clear();
    productsLoading.value = false;
    featuredLoading.value = false;
    productsError.value = '';
    featuredError.value = '';
    loadingByCategory.clear();
    errorByCategory.clear();
    productsVersion.value++;

    if (shouldReloadProducts) {
      await fetchProducts(force: true);
      return;
    }

    for (final categoryId in loadedCategoryIds) {
      await fetchProductsByCategory(categoryId, force: true);
    }
  }

  bool isLoading(int categoryId) => loadingByCategory[categoryId] ?? false;

  String errorFor(int categoryId) => errorByCategory[categoryId] ?? '';

  List<ProductItem> productsFor(int categoryId) =>
      productsByCategory[categoryId] ?? [];

  Future<void> _replaceLoadedCategoryBucketsFromProducts(int revision) async {
    final loadedCategoryIds = productsByCategory.keys.toList();
    for (final categoryId in loadedCategoryIds) {
      await _replaceCategoryBucketFromProducts(categoryId, revision);
    }
  }

  Future<void> _replaceCategoryBucketFromProducts(
    int categoryId,
    int revision,
  ) async {
    final baseProducts = products
        .where((product) => product.categoryId == categoryId)
        .toList();
    productsByCategory[categoryId] = await _withExtraProducts(
      categoryId,
      baseProducts,
      revision,
    );
    errorByCategory[categoryId] = '';
    loadingByCategory[categoryId] = false;
    productsByCategory.refresh();
    errorByCategory.refresh();
    loadingByCategory.refresh();
  }

  Future<List<ProductItem>> _withExtraProducts(
    int categoryId,
    List<ProductItem> source,
    int revision,
  ) async {
    final aliases = ProductCategories.extraProductsFor(categoryId);
    if (aliases.isEmpty) return source;

    final merged = [...source];
    final existingCodes = {
      for (final product in merged) product.productCode.toUpperCase(),
    };

    for (final alias in aliases) {
      if (revision != _revision) return merged;

      final code = alias.productCode.toUpperCase();
      if (existingCodes.contains(code)) continue;

      final product = await _findProductInCategory(
        sourceCategoryId: alias.sourceCategoryId,
        productCode: alias.productCode,
        revision: revision,
      );
      if (product == null) continue;

      merged.add(product);
      existingCodes.add(code);
    }

    return merged;
  }

  Future<ProductItem?> _findProductInCategory({
    required int sourceCategoryId,
    required String productCode,
    required int revision,
  }) async {
    final normalizedCode = productCode.toUpperCase();

    if (_productsLoaded) {
      return _findByProductCode(products, normalizedCode);
    }

    final cached = productsByCategory[sourceCategoryId];
    if (cached != null) {
      return _findByProductCode(cached, normalizedCode);
    }

    final res = await ApiMiddleware.products.getProductsByCategory(
      sourceCategoryId,
    );
    if (revision != _revision || !res.success) return null;

    final fetchedProducts = (res.data ?? const <ProductItem?>[])
        .whereType<ProductItem>()
        .toList();
    productsByCategory[sourceCategoryId] = fetchedProducts;
    return _findByProductCode(fetchedProducts, normalizedCode);
  }

  ProductItem? _findByProductCode(
    Iterable<ProductItem> productList,
    String normalizedCode,
  ) {
    for (final product in productList) {
      if (product.productCode.toUpperCase() == normalizedCode) {
        return product;
      }
    }
    return null;
  }
}
