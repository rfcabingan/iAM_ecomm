import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/products.cart/add_remove_button.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_item.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCartItems extends StatelessWidget {
  const IAMCartItems({
    super.key, this.showAddRemoveButtons = true,
  });

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (_, __) =>
          const SizedBox(height: IAMSizes.spaceBtwSections),
      itemCount: 2,
      itemBuilder: (_, index) => Column(
        children: [
          IAMCartItem(),
          if(showAddRemoveButtons) const SizedBox(height: IAMSizes.spaceBtwItems),
          
          if(showAddRemoveButtons)
            const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 85),
                  IAMProductQuantityWithAddRemoveButton(),
                ],
              ),
              IAMProductPriceText(price: '1000.00'),
            ],
          ),
        ],
      ),
    );
  }
}