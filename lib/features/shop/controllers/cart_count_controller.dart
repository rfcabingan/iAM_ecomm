import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';

class CartCountController extends GetxController {
  static CartCountController get instance => Get.find<CartCountController>();

  final RxInt count = 0.obs;

  Future<void> refresh() async {
    count.value = await _loadCartCount();
  }

  Future<int> _loadCartCount() async {
    final isLoggedIn = Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    if (isLoggedIn) {
      final res = await ApiMiddleware.cart.getCart();
      if (!res.success || res.data == null) return 0;
      return res.data!.totalQty;
    }

    final storage = IAMLocalStorage();
    final raw = storage.readData<List>('guest_cart') ?? const [];
    if (raw.isEmpty) return 0;

    var total = 0;
    for (final entry in raw) {
      final map = Map<String, dynamic>.from(entry as Map);
      total += (map['qty'] as int? ?? 0);
    }
    return total;
  }
}

