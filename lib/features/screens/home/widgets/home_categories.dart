import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';

class IAMHomeCategories extends StatelessWidget {
  const IAMHomeCategories({super.key});

  // Category data: [icon, title, tabIndex]
  static const List<Map<String, dynamic>> categories = [
    {
      'icon': IAMImages.jade,
      'title': 'IAM Packages',
      'tabIndex': 0,
    },
    {
      'icon': IAMImages.amazingBarley1,
      'title': 'Amazing Barley',
      'tabIndex': 1,
    },
    {
      'icon': IAMImages.deliciousJuiceDrinks1,
      'title': 'Delicious Juice Drinks',
      'tabIndex': 2,
    },
    {
      'icon': IAMImages.foodSupplements1,
      'title': 'Food Supplements',
      'tabIndex': 3,
    },
    {
      'icon': IAMImages.healthyCoffee1,
      'title': 'Healthy Coffee',
      'tabIndex': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final category = categories[index];
          return IAMVerticalImageText(
            image: category['icon'] as String,
            title: category['title'] as String,
            // These category icons are colored images; don't tint them.
            applyIconTint: false,
            onTap: () {
              final controller = Get.find<NavigationController>();
              controller.navigateToStore(category['tabIndex'] as int);
            },
          );
        },
      ),
    );
  }
}
