import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/home.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IAMCircularIcon(
            icon: Iconsax.add,
            onPressed: () => Get.to(const HomeScreen()),
          ),
        ],
      ),
      // BODY -- ITEMCOUNT WILL BE DYNAMIC ONCE BCKEND IS INTEGRATED
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              IAMGridLayout(
                itemCount: 6,
                itemBuilder: (_, index) => IAMProductCardVertical(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
