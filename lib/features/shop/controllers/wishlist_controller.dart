import 'package:get/get.dart';
import 'package:iam_ecomm/data/products_data.dart';
import 'package:iam_ecomm/features/shop/models/product_model.dart';

/// Mock wishlist controller (for UI/demo purposes).
///
/// Default wishlist items:
/// - IAM Choco Barley (id: 4)
/// - IAM Barley Pure Organic Powder (id: 14)
/// - Platinum Package (id: p5)
/// - Jade Package (id: p6)
class WishlistController extends GetxController {
  static WishlistController get instance => Get.find<WishlistController>();

  final RxSet<String> wishlistedIds = <String>{
    '4',
    '14',
    'p5',
    'p6',
  }.obs;

  bool isWishlisted(String id) => wishlistedIds.contains(id);

  List<IAMProductModel> get wishlistedItems => IAMProductsData.allItems
      .where((item) => wishlistedIds.contains(item.id))
      .toList();
}

