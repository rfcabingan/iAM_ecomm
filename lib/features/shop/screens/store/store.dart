import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/appbar/tabbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/data/products_data.dart';
import 'package:iam_ecomm/features/shop/screens/store/widgets/category_tab.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 5,
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
                // Reduce extra blank space between header content and tabs.
                expandedHeight: 370,

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

                      //Featured Items — Barley Gummies & Amazing Smile Toothpaste (horizontal cards)
                      IAMSectionHeading(
                        title: 'Featured Items',
                        showActionButton: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: IAMProductsData.featuredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: IAMSizes.spaceBtwItems),
                          itemBuilder: (_, index) => IAMProductCardHorizontal(
                            product: IAMProductsData.featuredItems[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Tabs
                bottom: IAMTabBar(
                  tabs: [
                    Tab(child: Text('IAM Packages')),
                    Tab(child: Text('Amazing Barley')),
                    //Tab(child: Text('Amazing Skin Care')),
                    Tab(child: Text('Delicious Juice Drinks')),
                    Tab(child: Text('Food Supplements')),
                    Tab(child: Text('Healthy Coffee')),
                    //Tab(child: Text('Protective Accessories')),
                    //Tab(child: Text('SJK Products')),
                  ],
                ),
              ),
            ];
          },
          //Body — Tab 0: packages only; Tabs 1-4: products filtered by category
          body: const TabBarView(
            children: [
              IAMCategoryTab(showPackagesOnly: true),
              IAMCategoryTab(showPackagesOnly: false, categoryName: 'Amazing Barley'),
              IAMCategoryTab(showPackagesOnly: false, categoryName: 'Delicious Juice Drinks'),
              IAMCategoryTab(showPackagesOnly: false, categoryName: 'Food Supplements'),
              IAMCategoryTab(showPackagesOnly: false, categoryName: 'Healthy Coffee'),
            ],
          ),
        ),
      ),
    );
  }
}
