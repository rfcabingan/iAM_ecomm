import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';

class IAMHomeCategories extends StatelessWidget {
  const IAMHomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 7,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return IAMVerticalImageText(
            image: IAMImages.amazingBarley,
            title: 'Amazing Barley',
            onTap: () {},
          );
        },
      ),
    );
  }
}
