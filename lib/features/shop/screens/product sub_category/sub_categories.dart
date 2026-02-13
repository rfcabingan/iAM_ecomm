import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(title: Text('Drinks'), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              IAMRoundedImage(
                width: double.infinity,
                imageUrl: IAMImages.banner1,
                applyImageRadius: true,
              ),
              SizedBox(height: IAMSizes.spaceBtwSections),

              Column(
                children: [
                  IAMSectionHeading(title: 'Barley Drinks', onPressed: () {}),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 2),

                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: IAMSizes.spaceBtwItems),
                      itemBuilder: (context, index) =>
                          const IAMProductCardHorizontal(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
