import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/appbar/tabbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_card.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/features/shop/screens/store/widgets/category_tab.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreController>()) {
      Get.put(StoreController());
    }

    return DefaultTabController(
      initialIndex: initialTabIndex.clamp(0, ProductCategories.ids.length - 1),
      length: ProductCategories.ids.length,
      child: Scaffold(
        appBar: IAMAppBar(
          title: Text(
            'Store',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [IAMCartCounterIcon(onPressed: () {})],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: IAMHelperFunctions.isDarkMode(context)
                    ? IAMColors.black
                    : IAMColors.white,
                expandedHeight: 440,

                flexibleSpace: Padding(
                  padding: EdgeInsets.all(IAMSizes.defaultSpace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      //Search Bar
                      SizedBox(height: IAMSizes.spaceBtwItems),
                      IAMSearchBar(
                        text: 'Search in Store',
                        showBorder: true,
                        showBackground: false,
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(height: IAMSizes.spaceBtwSections),

                      //Featured Categories
                      IAMSectionHeading(
                        title: 'Featured Items',
                        showActionButton: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                      IAMGridLayout(
                        itemCount: 4,
                        mainAxisExtent: 80,
                        itemBuilder: (_, index) {
                          return IAMBrandCard(showBorder: true);
                        },
                      ),
                    ],
                  ),
                ),

                //Tabs
                bottom: IAMTabBar(
                  tabs: ProductCategories.names
                      .map((name) => Tab(child: Text(name)))
                      .toList(),
                ),
              ),
            ];
          },
          //Body
          body: TabBarView(
            children: ProductCategories.ids
                .map((id) => IAMCategoryTab(categoryId: id))
                .toList(),
          ),
        ),
      ),
    );
  }
}
