import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/personalization/screens/settings/settings.dart';
import 'package:iam_ecomm/features/screens/home/home.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/features/shop/screens/store/store.dart';
import 'package:iam_ecomm/features/shop/screens/wishlist/wishlist.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final auth = AuthController.instance;
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            if (index == 0) {
              controller.navigateToHome();
              return;
            }
            controller.selectedIndex.value = index;
          },
          backgroundColor: darkMode ? IAMColors.black : Colors.white,
          indicatorColor: darkMode
              ? IAMColors.white.withValues(alpha: 0.1)
              : IAMColors.black.withValues(alpha: 0.1),
          destinations: [
            const NavigationDestination(
              icon: Icon(Iconsax.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Iconsax.shop),
              label: 'Store',
            ),
            const NavigationDestination(
              icon: Icon(Iconsax.heart),
              label: 'Wishlist',
            ),
            auth.isLoggedIn.value
                ? const NavigationDestination(
                    icon: Icon(Iconsax.user),
                    label: 'Profile',
                  )
                : const NavigationDestination(
                    icon: Icon(Iconsax.login),
                    label: 'Login',
                  ),
          ],
        ),
      ),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        final loggedIn = auth.isLoggedIn.value;
        // If navigating to Store, pass the initial tab index
        if (index == 1) {
          return StoreScreen(
            initialTabIndex: controller.storeInitialTabIndex.value,
          );
        }
        // If navigating to Profile/Settings, show Login when logged out
        if (index == 3 && !loggedIn) {
          return const LoginScreen();
        }
        return controller.screens[index];
      }),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final Rx<int> storeInitialTabIndex = 0.obs;
  Worker? _homeRefreshWorker;

  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    const FavouriteScreen(),
    const SettingScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
    _homeRefreshWorker = ever<int>(selectedIndex, (index) {
      if (index == 0) refreshHomeProducts();
    });
    refreshHomeProducts();
  }

  void refreshHomeProducts() {
    final homeControllerWasRegistered = Get.isRegistered<HomeController>();
    if (!homeControllerWasRegistered) {
      Get.put(HomeController());
    }
    if (homeControllerWasRegistered) {
      unawaited(Get.find<HomeController>().fetchProducts());
    }
  }

  void navigateToHome() {
    refreshHomeProducts();
    selectedIndex.value = 0;
  }

  void navigateToStore(int tabIndex) {
    storeInitialTabIndex.value = tabIndex;
    selectedIndex.value = 1; // Store tab index
  }

  void navigateToProfileOrLogin() => selectedIndex.value = 3;

  @override
  void onClose() {
    _homeRefreshWorker?.dispose();
    super.onClose();
  }
}
