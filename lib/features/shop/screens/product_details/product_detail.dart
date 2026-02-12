import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:readmore/readmore.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: IAMBottomAddToCart(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -- PRODUCT IMAGE SLIDER
            IAMProductImageSlider(),

            // -- PRDOUCT DETAILS
            Padding(
              padding: EdgeInsets.only(right: IAMSizes.defaultSpace, left: IAMSizes.defaultSpace, bottom: IAMSizes.defaultSpace,),
              child: Column(
                children: [
                  // -- RATINGS & SHARE BUTTON
                  IAMRatingAndShare(),

                  // -- PRICE, TITLE, STOCK, & BRAND
                  IAMProductMetaData(),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                  // -- ATTRIBUTES
                  IAMProductAttributes(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  // -- CHECOUT BUTTON
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){}, child: Text('Checkout'))),
                  const SizedBox(height: IAMSizes.spaceBtwSections,),

                  // -- DESCRIPTION
                  const IAMSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  const ReadMoreText(
                    'This AMAZING Pure Organic Barley Powdered Drink helps in the treatment and prevention of cancer. It has anti-diabetic content and helps regulate blood pressure and cholesterol level. It helps prevent hypertension and arthritis. Barley is also a source of relief from ulcerative colitis. It strengthens the immune system and regenerates damaged cells and tissues. It promotes agility and has rejuvenating effects on the entire body.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  
                  // -- REVIEWS
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const IAMSectionHeading(title: 'Review(19)', showActionButton: false,),
                      IconButton(onPressed: (){}, icon: const Icon(Iconsax.arrow_right_3, size: 18))
                    ],
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}