import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final carouselContextIndex = 0.obs;
  final products = <ProductItem>[].obs;
  final productsLoading = false.obs;
  final productsError = ''.obs;
  final productsVersion = 0.obs;
  List<ProductItem> get popularProducts =>
      products.where((p) => p.isPopular).toList();
  Worker? _authStateWorker;
  int _productsRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      _authStateWorker = ever<bool>(
        AuthController.instance.isLoggedIn,
        (_) => fetchProducts(),
      );
    }
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final requestId = ++_productsRequestId;
    productsLoading.value = true;
    productsError.value = '';
    final res = await ApiMiddleware.products.getProducts();
    if (requestId != _productsRequestId) return;
    productsLoading.value = false;
    if (!res.success) {
      productsError.value = res.message;
      products.clear();
      return;
    }
    final list = res.data ?? [];
    products.assignAll(list.whereType<ProductItem>());
    productsVersion.value++;
  }

  void updatePageIndicator(index) {
    carouselContextIndex.value = index;
  }

  @override
  void onClose() {
    _authStateWorker?.dispose();
    super.onClose();
  }
}
