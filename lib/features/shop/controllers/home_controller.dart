import 'package:get/get.dart';
import 'package:iam_ecomm/features/shop/controllers/product_cache_controller.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final ProductCacheController _cache =
      Get.isRegistered<ProductCacheController>()
          ? ProductCacheController.instance
          : Get.put(ProductCacheController(), permanent: true);

  final carouselContextIndex = 0.obs;
  RxList<ProductItem> get products => _cache.products;
  RxBool get productsLoading => _cache.productsLoading;
  RxString get productsError => _cache.productsError;
  RxInt get productsVersion => _cache.productsVersion;
  List<ProductItem> get popularProducts => _cache.popularProducts;

  @override
  void onInit() {
    super.onInit();
    _cache.ensureProducts();
  }

  Future<void> fetchProducts({bool force = false}) =>
      _cache.fetchProducts(force: force);

  void updatePageIndicator(index) {
    carouselContextIndex.value = index;
  }
}
