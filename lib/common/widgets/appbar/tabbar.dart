import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMTabBar extends StatelessWidget implements PreferredSizeWidget {
  const IAMTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? IAMColors.black : IAMColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: IAMColors.primary,
        labelColor: dark ? IAMColors.white : IAMColors.primary,
        unselectedLabelColor: IAMColors.darkGrey,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(IAMDeviceUtils.getAppBarHeight());
}
