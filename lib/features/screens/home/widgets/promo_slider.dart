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

  /// Keeps a banner-like proportion without fixed pixel dimensions.
  static const double _bannerAspectRatio = 725 / 450;

  static bool _isNetworkUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = IAMSizes.sm;
            const verticalPadding = IAMSizes.xs;
            final contentWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final contentHeight = contentWidth / _bannerAspectRatio;
            final carouselHeight = contentHeight + (verticalPadding * 2);

            return CarouselSlider(
              options: CarouselOptions(
                height: carouselHeight,
                viewportFraction: 1,
                onPageChanged: (index, _) =>
                    controller.updatePageIndicator(index),
              ),
              items: banners
                  .map(
                    (url) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: IAMRoundedImage(
                        imageUrl: url,
                        isNetworkImage: _isNetworkUrl(url),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
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
                    margin: const EdgeInsets.only(right: 10),
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
