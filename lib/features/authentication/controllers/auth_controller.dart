import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iconsax/iconsax.dart';

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
    user.value = userInfo;
    isLoggedIn.value = true;
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
      user.value = null;
      isLoggedIn.value = false;

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

    Get.dialog<void>(const _SessionExpiredDialog(), barrierDismissible: false);
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

class _SessionExpiredDialog extends StatelessWidget {
  const _SessionExpiredDialog();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final surfaceColor = dark ? const Color(0xFF1F1F1F) : IAMColors.white;
    final borderColor = dark
        ? IAMColors.primary.withValues(alpha: 0.30)
        : IAMColors.primary.withValues(alpha: 0.20);
    final bodyColor = dark ? IAMColors.lightGrey : IAMColors.textSecondary;
    final dialogWidth = MediaQuery.sizeOf(context).width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: IAMSizes.defaultSpace,
        vertical: IAMSizes.defaultSpace,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth >= 600 ? 420 : double.infinity,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: IAMColors.black.withValues(alpha: dark ? 0.38 : 0.14),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE8C45A),
                        IAMColors.primary,
                        Color(0xFF9B7421),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.lg,
                    IAMSizes.lg,
                    IAMSizes.lg,
                    IAMSizes.md,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: IAMColors.primary.withValues(
                            alpha: dark ? 0.18 : 0.14,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: IAMColors.primary.withValues(alpha: 0.36),
                          ),
                        ),
                        child: const Icon(
                          Iconsax.security_safe,
                          color: IAMColors.primary,
                          size: IAMSizes.iconLg,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.lg),
                      Text(
                        'Session timed out',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: dark ? IAMColors.white : IAMColors.black,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      Text(
                        'We signed you out after a period of inactivity to keep your account secure. Please sign in again to continue.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                          color: bodyColor,
                        ),
                      ),
                      const SizedBox(height: IAMSizes.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                IAMSizes.buttonRadius,
                              ),
                            ),
                          ),
                          child: const Text('Sign in again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
