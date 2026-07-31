import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/screens/home/widgets/iam_wallet_balance_sheet.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

/// Website-style top header used only on desktop web (not Android/iOS).
class IAMWebStorefrontHeader extends StatelessWidget {
  const IAMWebStorefrontHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final nav = Get.find<NavigationController>();
    final auth = AuthController.instance;
    final wide = MediaQuery.sizeOf(context).width >= IAMBreakpoints.desktop;

    return Material(
      color: dark ? IAMColors.black : IAMColors.white,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: IAMColors.primary.withValues(alpha: dark ? 0.35 : 0.45),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: IAMBreakpoints.contentMaxWidth + 80,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 28 : 18,
                  vertical: 10,
                ),
                child: Obx(() {
                  final index = nav.selectedIndex.value;
                  final loggedIn = auth.isLoggedIn.value;
                  return Row(
                    children: [
                      _BrandMark(onTap: nav.navigateToHome),
                      const SizedBox(width: 28),
                      if (wide) ...[
                        _NavLink(
                          label: 'Home',
                          selected: index == 0,
                          onTap: nav.navigateToHome,
                        ),
                        _NavLink(
                          label: 'Store',
                          selected: index == 1,
                          onTap: () => nav.selectedIndex.value = 1,
                        ),
                        _NavLink(
                          label: 'Wishlist',
                          selected: index == 2,
                          onTap: () => nav.selectedIndex.value = 2,
                        ),
                        _NavLink(
                          label: loggedIn ? 'Account' : 'Sign in',
                          selected: index == 3,
                          onTap: nav.navigateToProfileOrLogin,
                        ),
                        const Spacer(),
                      ] else ...[
                        const Spacer(),
                      ],
                      // Same actions as mobile home app bar: wallet then cart.
                      IconButton(
                        tooltip: 'IAM Wallet balance',
                        onPressed: () =>
                            showIamWalletBalanceQuickSheet(context),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Image.asset(
                          dark
                              ? IAMImages.walletIconW
                              : IAMImages.walletIcon,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          semanticLabel: 'IAM Wallet',
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance_wallet_outlined,
                            color: dark ? IAMColors.white : IAMColors.black,
                            size: 26,
                          ),
                        ),
                      ),
                      IAMCartCounterIcon(
                        onPressed: () {},
                        iconColor: dark ? IAMColors.white : IAMColors.black,
                      ),
                      if (!wide)
                        IconButton(
                          tooltip: 'Menu',
                          onPressed: () => _openCompactMenu(
                            context,
                            nav,
                            loggedIn,
                          ),
                          icon: const Icon(Iconsax.menu_1),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCompactMenu(
    BuildContext context,
    NavigationController nav,
    bool loggedIn,
  ) async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: const Icon(Iconsax.shop),
              title: const Text('Store'),
              onTap: () => Navigator.pop(context, 1),
            ),
            ListTile(
              leading: const Icon(Iconsax.heart),
              title: const Text('Wishlist'),
              onTap: () => Navigator.pop(context, 2),
            ),
            ListTile(
              leading: Icon(loggedIn ? Iconsax.user : Iconsax.login),
              title: Text(loggedIn ? 'Account' : 'Sign in'),
              onTap: () => Navigator.pop(context, 3),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 0) {
      nav.navigateToHome();
    } else {
      nav.selectedIndex.value = choice;
    }
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IAM',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: IAMColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    height: 1,
                  ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1,
              height: 18,
              color: IAMColors.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 10),
            Text(
              'STORE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w600,
                    color: IAMHelperFunctions.isDarkMode(context)
                        ? IAMColors.lightGrey
                        : IAMColors.darkerGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected
              ? IAMColors.primary
              : (dark ? IAMColors.lightGrey : IAMColors.darkerGrey),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2,
              width: selected ? 22 : 0,
              color: IAMColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
