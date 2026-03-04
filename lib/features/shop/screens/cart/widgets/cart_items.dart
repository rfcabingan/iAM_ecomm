import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/products.cart/add_remove_button.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_item.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCartItems extends StatelessWidget {
  const IAMCartItems({
    super.key,
    this.showAddRemoveButtons = true,
    this.showQuantity = false,
  });

  final bool showAddRemoveButtons;
  final bool showQuantity;

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
          if (showAddRemoveButtons || showQuantity)
            const SizedBox(height: IAMSizes.spaceBtwItems),

          if (showAddRemoveButtons)
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

          if (!showAddRemoveButtons && showQuantity)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 85),
                  child: Text('Qty: 2'),
                ),
                IAMProductPriceText(price: '1000.00'),
              ],
            ),
        ],
      ),
    );
  }
}
