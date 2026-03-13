import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  /// Cached products per category. Key = categoryId.
  final productsByCategory = <int, List<ProductItem>>{}.obs;

  /// Loading flag per category.
  final loadingByCategory = <int, bool>{}.obs;

  /// Error message per category.
  final errorByCategory = <int, String>{}.obs;

  Future<void> fetchProductsByCategory(int categoryId) async {
    loadingByCategory[categoryId] = true;
    errorByCategory[categoryId] = '';

    final res = await ApiMiddleware.products.getProductsByCategory(categoryId);
    loadingByCategory[categoryId] = false;
    errorByCategory[categoryId] = res.success ? '' : res.message;
    if (res.success) {
      final list = res.data ?? [];
      productsByCategory[categoryId] = list.whereType<ProductItem>().toList();
    } else {
      productsByCategory[categoryId] = [];
    }
  }

  bool isLoading(int categoryId) => loadingByCategory[categoryId] ?? false;
  String errorFor(int categoryId) => errorByCategory[categoryId] ?? '';
  List<ProductItem> productsFor(int categoryId) =>
      productsByCategory[categoryId] ?? [];
}
