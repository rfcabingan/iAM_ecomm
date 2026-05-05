import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/features/shop/controllers/cart_count_controller.dart';
import 'package:iconsax/iconsax.dart';

class IAMCartCounterIcon extends StatefulWidget {
  const IAMCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  State<IAMCartCounterIcon> createState() => _IAMCartCounterIconState();
}

class _IAMCartCounterIconState extends State<IAMCartCounterIcon> {
  late final CartCountController _cartCountController;

  @override
  void initState() {
    super.initState();
    _cartCountController = Get.isRegistered<CartCountController>()
        ? CartCountController.instance
        : Get.put(CartCountController());
    _cartCountController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            widget.onPressed();
            Get.to(() => const CartScreen())?.then((_) {
              if (!mounted) return;
              _cartCountController.refresh();
            });
          },
          icon: Icon(
            Iconsax.shopping_bag,
            color: widget.iconColor ?? Theme.of(context).iconTheme.color,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 2,
          child: Obx(() {
            final totalQty = _cartCountController.count.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: BoxDecoration(
                color: IAMColors.primary,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255)
                      .withOpacity(0.90),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$totalQty',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: IAMColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .fontSize! *
                        0.75,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
