import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:readmore/readmore.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product});

  final ProductItem? product;

  Future<void> _checkoutProduct(BuildContext context) async {
    final code = product?.productCode;
    if (code == null || code.isEmpty) return;

    const qty = 1;
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    if (!isLoggedIn) {
      final storage = IAMLocalStorage();
      final existing = storage.readData<List>('guest_cart') ?? [];
      final cart = existing
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final index = cart.indexWhere((e) => e['productCode'] == code);
      if (index >= 0) {
        final current = cart[index]['qty'] as int? ?? 0;
        cart[index]['qty'] = current + qty;
      } else {
        cart.add({'productCode': code, 'qty': qty});
      }
      await storage.saveData('guest_cart', cart);
      if (!context.mounted) return;
      Get.to(() => const CheckoutScreen());
      return;
    }

    final res = await ApiMiddleware.cart.add(productCode: code, qty: qty);
    if (!context.mounted) return;
    if (!res.success) {
      final msg = res.message.isNotEmpty
          ? res.message
          : 'Unable to add item to cart.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout failed: $msg',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }
    Get.to(() => const CartScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: IAMBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMProductImageSlider(product: product),
            Padding(
              padding: EdgeInsets.only(
                right: IAMSizes.defaultSpace,
                left: IAMSizes.defaultSpace,
                bottom: IAMSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  IAMRatingAndShare(),
                  IAMProductMetaData(product: product),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product != null
                          ? () => _checkoutProduct(context)
                          : null,
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  const IAMSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  ReadMoreText(
                    product?.longDesc.isNotEmpty == true
                        ? product!.longDesc
                        : 'No description available.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                        future: product?.productCode != null
                            ? ApiMiddleware.productReview.getReviews(
                                product!.productCode,
                              )
                            : null,
                        builder: (context, snapshot) {
                          int reviewCount = 0;

                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.success) {
                            final reviews = snapshot.data!.data ?? [];
                            reviewCount = reviews
                                .where((r) => r != null)
                                .length;
                          }

                          return IAMSectionHeading(
                            title: 'Review($reviewCount)',
                            showActionButton: false,
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.arrow_right_3, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: IAMSizes.spaceBtwSections),

                  FutureBuilder(
                    future: product?.productCode != null
                        ? ApiMiddleware.productReview.getReviews(
                            product!.productCode,
                          )
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data!.success) {
                        return const Text('No reviews found');
                      }

                      final reviews = snapshot.data!.data ?? [];

                      if (reviews.isEmpty) {
                        return const Text('No reviews yet');
                      }

                      return Column(
                        children: reviews.map((review) {
                          if (review == null) return const SizedBox();

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              bottom: IAMSizes.spaceBtwItems,
                            ),
                            padding: const EdgeInsets.all(IAMSizes.md),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(IAMSizes.sm),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.reviewComment ?? 'No comment',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rating: ${review.rating ?? 0}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
