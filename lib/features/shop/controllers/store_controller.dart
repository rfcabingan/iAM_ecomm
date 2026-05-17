import 'package:get/get.dart';
import 'package:iam_ecomm/features/shop/controllers/product_cache_controller.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  final ProductCacheController _cache =
      Get.isRegistered<ProductCacheController>()
          ? ProductCacheController.instance
          : Get.put(ProductCacheController(), permanent: true);

  /// Cached products per category. Key = categoryId.
  RxMap<int, List<ProductItem>> get productsByCategory =>
      _cache.productsByCategory;

  /// Loading flag per category.
  RxMap<int, bool> get loadingByCategory => _cache.loadingByCategory;

  /// Error message per category.
  RxMap<int, String> get errorByCategory => _cache.errorByCategory;

  RxList<ProductItem> get featuredProducts => _cache.featuredProducts;
  RxBool get featuredLoading => _cache.featuredLoading;
  RxString get featuredError => _cache.featuredError;

  Future<void> fetchProductsByCategory(int categoryId, {bool force = false}) =>
      _cache.fetchProductsByCategory(categoryId, force: force);

  /// Fetch featured products from /Products with isFeatured = true.
  Future<void> fetchFeaturedProducts({bool force = false}) =>
      _cache.fetchFeaturedProducts(force: force);

  bool isLoading(int categoryId) => _cache.isLoading(categoryId);
  String errorFor(int categoryId) => _cache.errorFor(categoryId);
  List<ProductItem> productsFor(int categoryId) =>
      _cache.productsFor(categoryId);
}
