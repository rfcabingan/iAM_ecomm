import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products.cart/coupon_widget.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_amount_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_payment_section.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(
          'Order Review',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              // -- ITEMS IN CART
              IAMCartItems(showAddRemoveButtons: false),
              SizedBox(height: IAMSizes.spaceBtwSections),

              // -- REFERRAL CODE or COUPON CODE
              IAMCouponCode(),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // -- BILLING SECTION
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  children: [
                    // -- PRICING
                    IAMBillingAmountSection(),
                    const SizedBox(height: IAMSizes.spaceBtwItems),

                    // -- DIVIDER
                    const Divider(),
                    const SizedBox(height: IAMSizes.spaceBtwItems),

                    // -- PAYMENT
                    IAMBillingPaymentSection(),
                    const SizedBox(height: IAMSizes.spaceBtwItems),

                    // -- ADDRESS
                    IAMBillingAddressSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // -- CHECKOUT BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => Get.to(
            () => SuccessScreen(
              image: IAMImages.successfulPaymentIcon,
              title: 'Payment Successful!',
              subTitle: 'Your items will be shipped soon!',
              onPressed: () => Get.offAll(() => const NavigationMenu()),
            ),
          ),
          child: Text('Checkout ₱1,250.00'),
        ),
      ),
    );
  }
}
