import 'dart:async';
import 'dart:io';
// 1
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/features/shop/controllers/product_cache_controller.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/product_detail.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/app_links.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:play_install_referrer/play_install_referrer.dart';

/// Handles referral deep links and Android Play install referrer data.  ,
class ReferralDeepLinkService {
  ReferralDeepLinkService._();

  static final ReferralDeepLinkService instance = ReferralDeepLinkService._();

  static const String pendingReferralKey = 'pending_referral_id';
  static const String installReferrerConsumedKey = 'install_referrer_consumed';
  static const String shouldPromptSignupKey = 'referral_should_prompt_signup';
  static const String pendingProductCodeKey = 'pending_shared_product_code';

  final _appLinks = AppLinks();
  final _storage = IAMLocalStorage();
  StreamSubscription<Uri>? _linkSubscription;
  Worker? _authLoginWorker;
  bool _appReadyHandled = false;
  bool _signupNavigationScheduled = false;
  bool _productNavigationScheduled = false;

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri, promptSignup: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReferralDeepLinkService initial link error: $e');
      }
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri, promptSignup: true),
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('ReferralDeepLinkService stream error: $e');
        }
      },
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _authLoginWorker?.dispose();
    _authLoginWorker = null;
  }

  /// Call once [GetMaterialApp] is mounted so signup navigation works.
  Future<void> handlePendingReferralAfterAppReady() async {
    if (_appReadyHandled) return;
    _appReadyHandled = true;

    // Give the navigator and first screen time to mount.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    await _readInstallReferrerIfNeeded();

    _registerAuthWorkerIfNeeded();
    final pendingProductCode = peekPendingProductCode();
    if (_isLoggedIn && pendingProductCode != null) {
      openSharedProduct(pendingProductCode);
      return;
    }

    final shouldPrompt =
        _storage.readData<bool>(shouldPromptSignupKey) ?? false;
    if (!shouldPrompt) return;

    final ref = peekPendingReferralId();
    if (ref == null || ref.isEmpty) {
      await _storage.removeData(shouldPromptSignupKey);
      return;
    }

    if (_isLoggedIn) {
      await _storage.removeData(shouldPromptSignupKey);
      return;
    }

    await _storage.removeData(shouldPromptSignupKey);
    openSignupWithReferral(ref);
  }

  bool get _isLoggedIn =>
      Get.isRegistered<AuthController>() &&
      AuthController.instance.isLoggedIn.value;

  String? parseReferralFromUri(Uri uri) {
    final ref = uri.queryParameters['ref']?.trim();
    if (ref != null && ref.isNotEmpty) return ref;

    if (!_isReferralUri(uri)) return null;

    // [temp] /r/{CODE} on iam-ecomm-share.vercel.app
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments.first == 'r') {
      final code = segments[1].trim();
      if (code.isNotEmpty) return code;
    }

    // [temp] legacy /signup/{CODE} path segment
    for (final segment in segments) {
      final trimmed = segment.trim();
      if (trimmed.isEmpty || trimmed == 'r' || trimmed == 'signup') {
        continue;
      }
      return trimmed;
    }

    return null;
  }

  String? parseProductCodeFromUri(Uri uri) {
    if (!_isProductShareUri(uri)) return null;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    if (uri.scheme == IamAppLinks.referralScheme &&
        uri.host == IamAppLinks.productHost) {
      final first = segments.first.trim();
      return first.isEmpty ? null : first;
    }

    if (segments.length >= 2 && segments.first == 'products') {
      final code = segments[1].trim();
      return code.isEmpty ? null : code;
    }

    return null;
  }

  bool _isReferralUri(Uri uri) {
    if (uri.scheme == IamAppLinks.referralScheme &&
        uri.host == IamAppLinks.referralHost) {
      return true;
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') return false;

    // [temp] Vercel share bridge: /r/{CODE}
    if (uri.host == IamAppLinks.referralWebHost) {
      return uri.path == IamAppLinks.referralWebPath ||
          uri.path.startsWith('${IamAppLinks.referralWebPath}/');
    }

    // [temp] legacy shop signup links
    if (uri.host == IamAppLinks.legacyReferralWebHost) {
      return uri.path == IamAppLinks.legacyReferralWebSignupPath ||
          uri.path.startsWith('${IamAppLinks.legacyReferralWebSignupPath}/');
    }

    return false;
  }

  bool _isProductShareUri(Uri uri) {
    if (uri.scheme == IamAppLinks.referralScheme &&
        uri.host == IamAppLinks.productHost) {
      return uri.pathSegments.isNotEmpty;
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    if (uri.host != IamAppLinks.referralWebHost) return false;

    return uri.path == IamAppLinks.productSharePath ||
        uri.path.startsWith('${IamAppLinks.productSharePath}/');
  }

  Future<void> _handleIncomingUri(Uri uri, {required bool promptSignup}) async {
    if (kDebugMode) {
      debugPrint('ReferralDeepLinkService incoming uri: $uri');
    }

    final productCode = parseProductCodeFromUri(uri);
    final ref = parseReferralFromUri(uri);
    final normalizedRef = ref?.trim() ?? '';
    if ((productCode == null || productCode.isEmpty) && normalizedRef.isEmpty) {
      return;
    }

    if (normalizedRef.isNotEmpty) {
      await _savePendingReferral(normalizedRef, promptSignup: promptSignup);
    }

    if (productCode != null && productCode.isNotEmpty) {
      await _storage.saveData(pendingProductCodeKey, productCode.trim());
      _registerAuthWorkerIfNeeded();

      if (_isLoggedIn) {
        openSharedProduct(productCode.trim());
        return;
      }
    }

    if (promptSignup && normalizedRef.isNotEmpty) {
      // [temp] Allow repeat opens from the web "Open in App" button.
      _signupNavigationScheduled = false;
      openSignupWithReferral(normalizedRef);
    }
  }

  Future<void> _readInstallReferrerIfNeeded() async {
    if (!Platform.isAndroid) return;

    final consumed =
        _storage.readData<bool>(installReferrerConsumedKey) ?? false;
    if (consumed) return;

    try {
      final ReferrerDetails details = await PlayInstallReferrer.installReferrer;
      await _storage.saveData(installReferrerConsumedKey, true);

      final referrer = details.installReferrer?.trim() ?? '';
      if (kDebugMode) {
        debugPrint('ReferralDeepLinkService install referrer: $referrer');
      }
      if (referrer.isEmpty) return;

      final ref = _parseReferrerString(referrer);
      if (ref != null && ref.isNotEmpty) {
        await _savePendingReferral(ref, promptSignup: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReferralDeepLinkService install referrer error: $e');
      }
    }
  }

  String? _parseReferrerString(String referrer) {
    final trimmed = referrer.trim();
    if (trimmed.isEmpty) return null;

    final decoded = Uri.decodeComponent(trimmed);
    final params = Uri.splitQueryString(decoded);
    final ref = params['ref']?.trim();
    if (ref != null && ref.isNotEmpty) return ref;

    final match = RegExp(r'(?:^|[?&])ref=([^&]+)').firstMatch(decoded);
    return match?.group(1)?.trim();
  }

  Future<void> _savePendingReferral(
    String referralId, {
    required bool promptSignup,
  }) async {
    await _storage.saveData(pendingReferralKey, referralId.trim());
    if (promptSignup) {
      await _storage.saveData(shouldPromptSignupKey, true);
    }
  }

  String? peekPendingReferralId() {
    final ref = _storage.readData<String>(pendingReferralKey)?.trim();
    if (ref == null || ref.isEmpty) return null;
    return ref;
  }

  String? consumePendingReferralId() {
    final ref = peekPendingReferralId();
    if (ref == null) return null;
    _storage.removeData(pendingReferralKey);
    return ref;
  }

  String? peekPendingProductCode() {
    final code = _storage.readData<String>(pendingProductCodeKey)?.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  Future<void> clearSignupPromptOnly() async {
    await _storage.removeData(shouldPromptSignupKey);
  }

  Future<void> clearPendingReferralAttribution() async {
    await _storage.removeData(pendingReferralKey);
    await _storage.removeData(shouldPromptSignupKey);
  }

  Future<void> clearPendingProductCode() async {
    await _storage.removeData(pendingProductCodeKey);
  }

  void _registerAuthWorkerIfNeeded() {
    if (_authLoginWorker != null) return;
    if (!Get.isRegistered<AuthController>()) return;

    _authLoginWorker = ever<bool>(AuthController.instance.isLoggedIn, (
      loggedIn,
    ) {
      if (loggedIn != true) return;
      final pendingProductCode = peekPendingProductCode();
      if (pendingProductCode == null) return;
      openSharedProduct(pendingProductCode);
    });
  }

  void openSharedProduct(String productCode) {
    final code = productCode.trim();
    if (code.isEmpty) return;
    if (_productNavigationScheduled) return;
    _productNavigationScheduled = true;

    Future<void> navigate({int attempt = 0}) async {
      final navigator = Get.key.currentState;
      if (navigator == null) {
        if (attempt < 20) {
          SchedulerBinding.instance.addPostFrameCallback(
            (_) => navigate(attempt: attempt + 1),
          );
        } else {
          _productNavigationScheduled = false;
        }
        return;
      }

      ProductItem? product;
      if (Get.isRegistered<ProductCacheController>()) {
        final cache = ProductCacheController.instance;
        await cache.ensureProducts();
        product = cache.productByCode(code);
      }
      product ??= (await ApiMiddleware.products.getProductDetail(code)).data;

      if (product != null) {
        Get.to(() => ProductDetailScreen(product: product));
        await _storage.removeData(pendingProductCodeKey);
      }
      _productNavigationScheduled = false;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      navigate();
    });
  }

  void openSignupWithReferral(String referralId) {
    final ref = referralId.trim();
    if (ref.isEmpty) return;
    if (_isLoggedIn) return;
    if (_signupNavigationScheduled) return;
    _signupNavigationScheduled = true;

    void navigate({int attempt = 0}) {
      if (_isLoggedIn) {
        _signupNavigationScheduled = false;
        return;
      }

      final navigator = Get.key.currentState;
      if (navigator == null) {
        if (attempt < 20) {
          SchedulerBinding.instance.addPostFrameCallback(
            (_) => navigate(attempt: attempt + 1),
          );
        } else {
          _signupNavigationScheduled = false;
        }
        return;
      }

      // [temp] Replace current route so repeat link clicks always land on signup.
      Get.off(() => SignupScreen(initialReferralId: ref));
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        _signupNavigationScheduled = false;
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((_) => navigate());
  }
}
