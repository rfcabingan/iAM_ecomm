import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class WishlistToggleResult {
  final bool wishlisted;
  final String message;

  const WishlistToggleResult({
    required this.wishlisted,
    required this.message,
  });
}

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find<WishlistController>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Server wishlist items.
  final RxList<WishlistItem> items = <WishlistItem>[].obs;

  /// Cached "is wishlisted?" state per product code.
  final RxMap<String, bool> wishlistedByCode = <String, bool>{}.obs;

  /// Prevent concurrent toggles per product code.
  final RxMap<String, bool> togglingByCode = <String, bool>{}.obs;

  bool _itemsLoaded = false;
  int _revision = 0;
  Future<void>? _loadRequest;

  @override
  void onInit() {
    super.onInit();
    ever(AuthController.instance.isLoggedIn, (_) => refreshForAuthChange());
  }

  bool isWishlisted(String productCode) =>
      wishlistedByCode[productCode] ?? false;

  bool isToggling(String productCode) =>
      togglingByCode[productCode] ?? false;

  Future<void> loadWishlistItems({bool force = false}) async {
    if (!force && _itemsLoaded) return;
    if (_loadRequest != null) return _loadRequest!;

    final request = _loadWishlistItems(force: force, revision: _revision);
    _loadRequest = request;
    await request;
    if (_loadRequest == request) {
      _loadRequest = null;
    }
  }

  Future<void> _loadWishlistItems({
    required bool force,
    required int revision,
  }) async {
    // Optional: clear UI when user is logged out.
    if (!AuthController.instance.isLoggedIn.value) {
      items.clear();
      wishlistedByCode.clear();
      togglingByCode.clear();
      errorMessage.value = '';
      _itemsLoaded = false;
      return;
    }

    loading.value = true;
    errorMessage.value = '';

    try {
      final res = await ApiMiddleware.wishlist.getWishlist();
      if (revision != _revision) return;
      loading.value = false;

      if (!res.success) {
        errorMessage.value = res.message;
        if (force || items.isEmpty) {
          items.clear();
          wishlistedByCode.clear();
          _itemsLoaded = false;
        }
        return;
      }

      final list = res.data ?? const <WishlistItem?>[];
      items.assignAll(list.whereType<WishlistItem>());

      final map = <String, bool>{};
      for (final item in items) {
        map[item.productCode] = true;
      }
      wishlistedByCode.value = map;
      _itemsLoaded = true;
    } catch (_) {
      if (revision != _revision) return;
      loading.value = false;
      errorMessage.value = 'Something went wrong.';
      if (force || items.isEmpty) {
        items.clear();
        wishlistedByCode.clear();
        _itemsLoaded = false;
      }
    }
  }

  Future<void> refreshForAuthChange() async {
    final shouldReload = _itemsLoaded || items.isNotEmpty;
    _revision++;
    _itemsLoaded = false;
    _loadRequest = null;
    items.clear();
    wishlistedByCode.clear();
    togglingByCode.clear();
    loading.value = false;
    errorMessage.value = '';

    if (AuthController.instance.isLoggedIn.value && shouldReload) {
      await loadWishlistItems(force: true);
    }
  }

  Future<bool?> _fetchIsWishlisted(String productCode) async {
    final res = await ApiMiddleware.wishlist.checkWishlist(productCode);
    if (!res.success) return null;
    return res.data?.isWishlisted;
  }

  Future<WishlistToggleResult> toggleWishlist(String productCode) async {
    if (!AuthController.instance.isLoggedIn.value) {
      return const WishlistToggleResult(
        wishlisted: false,
        message: 'Please login to use wishlist.',
      );
    }

    if (isToggling(productCode)) {
      return WishlistToggleResult(
        wishlisted: isWishlisted(productCode),
        message: '',
      );
    }

    togglingByCode[productCode] = true;
    togglingByCode.refresh();

    try {
      final hasCached = wishlistedByCode.containsKey(productCode);
      final isWishlisted = hasCached
          ? wishlistedByCode[productCode] ?? false
          : (await _fetchIsWishlisted(productCode) ?? false);

      if (isWishlisted) {
        final res = await ApiMiddleware.wishlist.removeWishlist(productCode);
        if (res.success) {
          // Keep UI snappy on remove.
          wishlistedByCode[productCode] = false;
          wishlistedByCode.refresh();
          items.removeWhere((e) => e.productCode == productCode);

          return WishlistToggleResult(
            wishlisted: false,
            message: 'Removed from wishlist.',
          );
        }

        return WishlistToggleResult(
          wishlisted: true,
          message: res.message.isNotEmpty
              ? res.message
              : 'Unable to remove from wishlist.',
        );
      } else {
        final res = await ApiMiddleware.wishlist.addWishlist(productCode);
        if (res.success) {
          // Reload to get full server item data.
          await loadWishlistItems(force: true);
          return const WishlistToggleResult(
            wishlisted: true,
            message: 'Added to wishlist.',
          );
        }

        return WishlistToggleResult(
          wishlisted: false,
          message: res.message.isNotEmpty
              ? res.message
              : 'Unable to add to wishlist.',
        );
      }
    } catch (_) {
      return WishlistToggleResult(
        wishlisted: isWishlistedFromCacheOrFalse(productCode),
        message: 'Something went wrong.',
      );
    } finally {
      togglingByCode[productCode] = false;
      togglingByCode.refresh();
    }
  }

  bool isWishlistedFromCacheOrFalse(String productCode) =>
      wishlistedByCode[productCode] ?? false;
}
