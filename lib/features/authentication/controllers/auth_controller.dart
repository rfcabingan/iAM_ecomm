import 'dart:async';

import 'package:get/get.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';

/// Mock auth controller (for UI/demo purposes).
///
/// - Starts logged out
/// - Call [login] to mark as logged in
/// - Call [logout] to mark as logged out
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final RxBool isLoggedIn = false.obs;
  final Rx<UserInfo?> user = Rx<UserInfo?>(null);
  Timer? _idleTimer;
  DateTime? _lastActivityAt;
  DateTime? _lastStoredActivityAt;
  bool _isLoggingOut = false;

  bool get isGuest {
    final id = user.value?.idno ?? '';
    if (id.isEmpty) return false;
    return id.toUpperCase().startsWith('NON');
  }

  bool get isMemberAccount {
    final id = user.value?.idno ?? '';
    if (id.isEmpty) return false;
    if (isGuest) return false;
    return RegExp(r'^\d{8}$').hasMatch(id);
  }

  bool get isMember {
    final u = user.value;
    if (u == null) return false;
    if (isGuest) return false;
    if (u.isMember) return true;
    return isMemberAccount;
  }

  void login(UserInfo? userInfo) {
    isLoggedIn.value = true;
    user.value = userInfo;
    recordUserActivity();
  }

  void recordUserActivity() {
    if (!isLoggedIn.value) return;

    final now = DateTime.now();
    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt != null &&
        now.difference(lastActivityAt) >= IAMLocalStorage.authIdleTimeout) {
      logout(showSessionExpiredMessage: true);
      return;
    }

    _lastActivityAt = now;
    _saveLastActivityAt(now);
    _restartIdleTimer();
  }

  void checkIdleTimeout() {
    if (!isLoggedIn.value) return;

    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt == null) {
      recordUserActivity();
      return;
    }

    if (DateTime.now().difference(lastActivityAt) >=
        IAMLocalStorage.authIdleTimeout) {
      logout(showSessionExpiredMessage: true);
    } else {
      _restartIdleTimer();
    }
  }

  void persistCurrentActivity() {
    final lastActivityAt = _lastActivityAt;
    if (!isLoggedIn.value || lastActivityAt == null) return;
    _saveLastActivityAt(lastActivityAt, force: true);
  }

  Future<void> logout({bool showSessionExpiredMessage = false}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      _idleTimer?.cancel();
      _idleTimer = null;
      _lastActivityAt = null;
      _lastStoredActivityAt = null;

      await ApiMiddleware.clearToken();
      await IAMLocalStorage().removeData(IAMLocalStorage.authLastActivityAtKey);
      isLoggedIn.value = false;
      user.value = null;

      final navController = Get.isRegistered<NavigationController>()
          ? Get.find<NavigationController>()
          : Get.put(NavigationController());
      navController.selectedIndex.value = 3;

      Get.offAll(() => const NavigationMenu());

      if (showSessionExpiredMessage) {
        unawaited(
          Future<void>.delayed(Duration.zero, _showSessionExpiredDialog),
        );
      }
    } finally {
      _isLoggingOut = false;
    }
  }

  void _showSessionExpiredDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.defaultDialog(
      title: 'Session terminated',
      middleText:
          'Your session has been terminated because your account was idle for too long. Please sign in again to continue.',
      textConfirm: 'OK',
      barrierDismissible: false,
      onConfirm: () => Get.back(),
    );
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(IAMLocalStorage.authIdleTimeout, () {
      logout(showSessionExpiredMessage: true);
    });
  }

  void _saveLastActivityAt(DateTime value, {bool force = false}) {
    final lastStoredActivityAt = _lastStoredActivityAt;
    if (!force &&
        lastStoredActivityAt != null &&
        value.difference(lastStoredActivityAt) < const Duration(minutes: 1)) {
      return;
    }

    _lastStoredActivityAt = value;
    unawaited(
      IAMLocalStorage().saveData(
        IAMLocalStorage.authLastActivityAtKey,
        value.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void onClose() {
    _idleTimer?.cancel();
    super.onClose();
  }
}
