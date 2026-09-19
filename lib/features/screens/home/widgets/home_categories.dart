import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';

class IAMHomeCategories extends StatelessWidget {
  const IAMHomeCategories({super.key});

  static const List<String> _categoryImages = [
    IAMImages.jade,
    IAMImages.amazingBarley1,
    //IAMImages.amazingSkinCare,
    IAMImages.deliciousJuiceDrinks1,
    IAMImages.foodSupplements1,
    IAMImages.healthyCoffee1,
  ];

  // Check if user is a logged-in member
  bool get _isMember {
    if (!Get.isRegistered<AuthController>()) return false;
    return AuthController.instance.isMember;
  }

  @override
  Widget build(BuildContext context) {
    // Filter out packages category if user is not a member
    final visibleCategories = _isMember
        ? ProductCategories.ids.asMap().entries.toList()
        : ProductCategories.ids.asMap().entries.where((entry) => entry.value != ProductCategories.iamPackages).toList();

    return SizedBox(
      height: 105,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: visibleCategories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final entry = visibleCategories[index];
          final originalIndex = entry.key;
          final name = ProductCategories.names[originalIndex];
          final image = originalIndex < _categoryImages.length
              ? _categoryImages[originalIndex]
              : IAMImages.sjkProducts;
          return IAMVerticalImageText(
            image: image,
            title: name,
            applyIconTint: false,
            onTap: () {
              // Navigate to store with the original index (tab position)
              // This ensures the correct tab is selected even if we filter out packages
              Get.find<NavigationController>().navigateToStore(originalIndex);
            },
          );
        },
      ),
    );
  }
}
