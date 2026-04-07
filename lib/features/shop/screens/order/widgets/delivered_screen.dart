import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:intl/intl.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class DeliveredTab extends StatelessWidget {
  const DeliveredTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiMiddleware.orders.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          return const Center(child: Text('No orders found'));
        }

        final orders = (snapshot.data!.data ?? [])
            .where(
              (order) =>
                  order != null &&
                  order.orderStatusName.toLowerCase() == 'delivered',
            )
            .toList();

        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: orders.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final order = orders[index];
            if (order == null) return const SizedBox.shrink();

            DateTime orderDate;
            try {
              orderDate = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).parse(order.orderDate);
            } catch (_) {
              orderDate = DateTime.now();
            }

            return _orderCard(context, order, orderDate);
          },
        );
      },
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(BuildContext context, OrderItem order, DateTime orderDate) {
    return FutureBuilder<ApiResponse<OrderDetailItem?>>(
      future: ApiMiddleware.orders.getOrderDetail(order.orderRefno),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IAMRoundedContainer(
            padding: const EdgeInsets.all(IAMSizes.md),
            backgroundColor: IAMColors.light,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !(snapshot.data?.success ?? false) ||
            snapshot.data!.data == null) {
          return IAMRoundedContainer(
            padding: const EdgeInsets.all(IAMSizes.md),
            backgroundColor: IAMColors.light,
            child: const Text('Failed to load order details'),
          );
        }

        final orderDetail = snapshot.data!.data!;
        final items = orderDetail.items ?? [];

        return IAMRoundedContainer(
          padding: const EdgeInsets.all(IAMSizes.md),
          backgroundColor: IAMColors.light,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- HEADER ----------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: IAMColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.tick_circle,
                      size: 20,
                      color: IAMColors.grey,
                    ),
                  ),
                  const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderStatusName,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: IAMColors.primary,
                          fontWeightDelta: 1,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd-MMM-yyyy, hh:mma',
                        ).format(DateTime.parse(order.orderDate)),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems),

              /// ---------------- ORDER NUMBER ----------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: IAMColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.hashtag,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Order ${order.orderRefno}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems),

              /// ---------------- ITEM LIST ----------------
              Column(
                children: items.where((item) => item != null).map((item) {
                  final nonNullItem = item!;
                  return _itemRow(
                    nonNullItem.productName ?? 'Unnamed Product',
                    NumberFormat.currency(
                      locale: 'en_PH',
                      symbol: '₱',
                      decimalDigits: 2,
                    ).format(nonNullItem.sellingPrice ?? 0),
                    'x${nonNullItem.qty ?? 1}',
                    nonNullItem.imageUrl,
                  );
                }).toList(),
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              /// ---------------- TOTAL ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Total',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_PH',
                      symbol: '₱',
                      decimalDigits: 2,
                    ).format(orderDetail.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Divider(color: Colors.grey[300]),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              /// ---------------- ACTIONS ----------------
              Row(
                children: [
                  /// RATE BUTTON
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRatingModal(context),
                      icon: const Icon(Iconsax.star, size: 18),
                      label: const Text('Rate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: IAMColors.dark,
                        side: const BorderSide(color: IAMColors.grey),
                        padding: const EdgeInsets.symmetric(
                          vertical: IAMSizes.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: IAMSizes.spaceBtwItems),

                  /// BUY AGAIN BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IAMColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: IAMSizes.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Buy Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ---------------- ITEM ROW ----------------
  Widget _itemRow(String title, String price, String qty, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          /// IMAGE
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(IAMSizes.sm),
              image: (imageUrl != null && imageUrl.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (imageUrl == null || imageUrl.isEmpty)
                ? const Icon(Iconsax.box, size: 20)
                : null,
          ),

          const SizedBox(width: IAMSizes.spaceBtwItems),

          /// NAME
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          /// PRICE + QTY
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price),
              Text(
                qty,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- SHOW RATING MODAL ----------------
  void _showRatingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: IAMColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: IAMSizes.md,
            right: IAMSizes.md,
            top: IAMSizes.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + IAMSizes.md,
          ),
          child: _RatingSheet(),
        );
      },
    );
  }
}

/// ---------------- RATING SHEET ----------------
class _RatingSheet extends StatefulWidget {
  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: IAMSizes.md),
        const Text(
          'Rate this order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: IAMSizes.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < _rating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isSelected ? Iconsax.star1 : Iconsax.star,
                  color: isSelected ? IAMColors.primary : Colors.grey,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: IAMSizes.md),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: IAMSizes.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: IAMColors.dark,
                  side: const BorderSide(color: IAMColors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  print('Rating: $_rating');
                  print('Comment: ${_commentController.text}');
                  Navigator.of(context).pop();
                },
                child: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IAMColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: IAMSizes.md),
      ],
    );
  }
}
