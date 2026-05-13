import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  /// Cached products per category. Key = categoryId.
  final productsByCategory = <int, List<ProductItem>>{}.obs;

  /// Loading flag per category.
  final loadingByCategory = <int, bool>{}.obs;

  /// Error message per category.
  final errorByCategory = <int, String>{}.obs;

  final featuredProducts = <ProductItem>[].obs;
  final featuredLoading = false.obs;
  final featuredError = ''.obs;

  Future<void> fetchProductsByCategory(int categoryId) async {
    print('Fetching products for category $categoryId');
    loadingByCategory[categoryId] = true;
    errorByCategory[categoryId] = '';

    try {
      final res = await ApiMiddleware.products.getProductsByCategory(
        categoryId,
      );
      print('API response status: ${res.status}, success: ${res.success}');
      print('API response data length: ${res.data?.length ?? 0}');

      errorByCategory[categoryId] = res.success ? '' : res.message;
      if (res.success) {
        final list = res.data ?? [];
        final products = list.whereType<ProductItem>().toList();
        productsByCategory[categoryId] = await _withExtraProducts(
          categoryId,
          products,
        );
        print(
          'Products loaded: ${productsByCategory[categoryId]?.length ?? 0}',
        );
      } else {
        productsByCategory[categoryId] = [];
        print('API error: ${res.message}');
      }
      loadingByCategory[categoryId] = false;
    } catch (e) {
      print('Exception in fetchProductsByCategory: $e');
      loadingByCategory[categoryId] = false;
      errorByCategory[categoryId] = 'Network error: $e';
      productsByCategory[categoryId] = [];
    }
  }

  /// Fetch featured products from /Products with isFeatured = true.
  Future<void> fetchFeaturedProducts() async {
    featuredLoading.value = true;
    featuredError.value = '';
    final res = await ApiMiddleware.products.getProducts();
    featuredLoading.value = false;
    if (!res.success) {
      featuredError.value = res.message;
      featuredProducts.clear();
      return;
    }
    final list = res.data ?? [];
    featuredProducts.assignAll(
      list.whereType<ProductItem>().where((p) => p.isFeatured),
    );
  }

  bool isLoading(int categoryId) => loadingByCategory[categoryId] ?? false;
  String errorFor(int categoryId) => errorByCategory[categoryId] ?? '';
  List<ProductItem> productsFor(int categoryId) =>
      productsByCategory[categoryId] ?? [];

  Future<List<ProductItem>> _withExtraProducts(
    int categoryId,
    List<ProductItem> products,
  ) async {
    final aliases = ProductCategories.extraProductsFor(categoryId);
    if (aliases.isEmpty) return products;

    final merged = [...products];
    final existingCodes = {
      for (final product in merged) product.productCode.toUpperCase(),
    };

    for (final alias in aliases) {
      final code = alias.productCode.toUpperCase();
      if (existingCodes.contains(code)) continue;

      final product = await _findProductInCategory(
        sourceCategoryId: alias.sourceCategoryId,
        productCode: alias.productCode,
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
  }) async {
    final cached = productsByCategory[sourceCategoryId];
    final normalizedCode = productCode.toUpperCase();
    if (cached != null) {
      return _findByProductCode(cached, normalizedCode);
    }

    final res = await ApiMiddleware.products.getProductsByCategory(
      sourceCategoryId,
    );
    if (!res.success) return null;

    final products = (res.data ?? []).whereType<ProductItem>().toList();
    productsByCategory[sourceCategoryId] = products;
    return _findByProductCode(products, normalizedCode);
  }

  ProductItem? _findByProductCode(
    List<ProductItem> products,
    String normalizedCode,
  ) {
    for (final product in products) {
      if (product.productCode.toUpperCase() == normalizedCode) {
        return product;
      }
    }
    return null;
  }
}
