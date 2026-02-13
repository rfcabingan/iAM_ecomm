import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMProductImageSlider extends StatelessWidget {
  const IAMProductImageSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    
    return IAMCurvedEdgeWidget(
      child: Container(
        color: dark ? IAMColors.darkerGrey : IAMColors.light,
        child: Stack(
          children: [
            // -- MAIN IMAGE
            SizedBox(
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(
                  IAMSizes.productImageRadius * 2,
                ),
                child: Center(
                  child: Image(image: AssetImage(IAMImages.pibarpow)),
                ),
              ),
            ),
    
            // -- IMAGE SLIDER
            Positioned(
              right: 0,
              bottom: 30,
              left: IAMSizes.defaultSpace,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: IAMSizes.spaceBtwItems),
                  itemCount: 6,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (_, index) => IAMRoundedImage(
                    width: 80,
                    backgroundColor: dark
                        ? IAMColors.dark
                        : IAMColors.white,
                    border: Border.all(color: IAMColors.primary),
                    padding: const EdgeInsets.all(IAMSizes.sm),
                    imageUrl: IAMImages.piacaibr,
                  ),
                ),
              ),
            ),
    
            // -- APPBAR ICONS
            const IAMAppBar(
              showBackArrow: true,
              actions: [
                IAMCircularIcon(icon: Iconsax.heart5, color: Colors.red,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
