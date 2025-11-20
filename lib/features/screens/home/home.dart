import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_appbar.dart';
import 'package:iam_ecomm/features/screens/home/widgets/home_categories.dart';
import 'package:iam_ecomm/features/screens/home/widgets/promo_slider.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMPrimaryHeaderContainer(
              child: Column(
                children: [
                  //Appbar
                  const IAMHomeAppBar(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  //Searchbar
                  IAMSearchBar(text: 'Search in Store'),
                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  //Categories
                  Padding(
                    padding: EdgeInsets.only(left: IAMSizes.defaultSpace),
                    child: Column(
                      children: [
                        //heading
                        IAMSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: IAMSizes.spaceBtwItems),

                        //Categories
                        IAMHomeCategories(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Body
            Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  IAMPromoSlider(
                    banners: [
                      IAMImages.banner1,
                      IAMImages.banner2,
                      IAMImages.banner3,
                    ],
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  //Heading
                  IAMSectionHeading(
                    title: 'Popular Products',
                    onPressed: () {},
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  IAMGridLayout(
                    itemCount: 4,
                    itemBuilder: (_, index) => const IAMProductCardVertical(),
                  ),
                ],
              ),

              // Popular products
            ),
          ],
        ),
      ),
    );
  }
}
