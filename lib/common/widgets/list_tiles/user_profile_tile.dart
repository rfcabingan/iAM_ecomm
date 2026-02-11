import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMUserProfile extends StatelessWidget {
  const IAMUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IAMCircularImage(
        image: IAMImages.pandauser,
        width: 50,
        height: 50,
        padding: 0,
      ),
      title: Text(
        'IAM User',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall!.apply(color: IAMColors.white),
      ),
      subtitle: Text(
        '@iamusername',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.apply(color: IAMColors.white),
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Iconsax.edit, color: IAMColors.white),
      ),
    );
  }
}
