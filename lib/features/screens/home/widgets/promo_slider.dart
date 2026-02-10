import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';

import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMPromoSlider extends StatelessWidget {
  const IAMPromoSlider({super.key, required this.banners});

  final List<String> banners;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: banners.map((url) => IAMRoundedImage(imageUrl: url)).toList(),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        Center(
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++)
                  IAMCircularContainer(
                    width: 20,
                    height: 4,
                    margin: EdgeInsets.only(right: 10),
                    backgroundColor: controller.carouselContextIndex.value == i
                        ? IAMColors.primary
                        : IAMColors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
