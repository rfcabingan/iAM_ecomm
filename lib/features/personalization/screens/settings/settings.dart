import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //HEADER
            IAMPrimaryHeaderContainer(
              child: Column(
                children: [
                  IAMAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: IAMColors.white),
                    ),
                  ),

                  //user profile card
                  const IAMUserProfile(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),

            //body
            Padding(
              padding: EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  //  ACCOUNT SETTIGNS
                  IAMSectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  SizedBox(height: IAMSizes.spaceBtwItems),

                  IAMSettingMenu(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set Shopping delivery address',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subTitle: 'Add, remove products and move to checkout',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.bag_tick,
                    title: 'My Orders',
                    subTitle: 'Track In-progress and Completed Orders',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.bank,
                    title: 'Bank Account',
                    subTitle: 'Withdraw balance to registered bank account',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.discount_shape,
                    title: 'My Coupons',
                    subTitle: 'Manage Discount Coupons',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subTitle: 'Set Notifications',
                  ),
                  IAMSettingMenu(
                    icon: Iconsax.security_card,
                    title: 'Account Privacy',
                    subTitle: 'Manage data usage and connected accounts',
                  ),

                  /// -- App Settings
                  SizedBox(height: IAMSizes.spaceBtwSections),
                  IAMSectionHeading(
                    title: 'App Settings',
                    showActionButton: false,
                  ),

                  SizedBox(height: IAMSizes.spaceBtwItems),
                  // IAMSettingMenu(
                  //   icon: Iconsax.document_upload,
                  //   title: 'Load Data',
                  //   subTitle: 'Upload Data to your Cloud Firebase',
                  // ),
                  IAMSettingMenu(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subTitle: 'Set recommendation based on location',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ), // IAMSettingMenu
                  // IAMSettingMenu(
                  //   icon: Iconsax.security_user,
                  //   title: 'Safe Mode',
                  //   subTitle: 'Search result is safe for all ages',
                  //   trailing: Switch(value: false, onChanged: (value) {}),
                  // ), // IAMSettingMenu
                  IAMSettingMenu(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subTitle: 'Set image quality to be seen',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

                  //Logout Button
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections * 2.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
