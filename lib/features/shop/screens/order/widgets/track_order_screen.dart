import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';

class TrackingOrderScreen extends StatelessWidget {
  final OrderDetailItem order;
  final user = AuthController.instance.user.value;

  TrackingOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tracking Result'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.md),
        child: Column(
          children: [
            _productCard(),
            const SizedBox(height: IAMSizes.spaceBtwSections),
            _orderDetails(),
            const SizedBox(height: IAMSizes.spaceBtwSections),
            Expanded(child: _timeline()),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _productCard() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(IAMSizes.md),
              image:
                  (order.items?.isNotEmpty == true &&
                      order.items!.first?.imageUrl != null &&
                      order.items!.first!.imageUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(order.items!.first!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                (order.items?.isNotEmpty != true ||
                    order.items!.first?.imageUrl == null ||
                    order.items!.first!.imageUrl!.isEmpty)
                ? const Icon(Iconsax.box)
                : null,
          ),
          const SizedBox(width: IAMSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.items?.isNotEmpty == true
                      ? (order.items!.first?.productName ?? 'Item Name')
                      : 'Item Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${order.orderRefno}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.copy, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Widget _orderDetails() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: IAMColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Order Details',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: IAMColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.paymentStatusMessage,
                  style: const TextStyle(
                    color: IAMColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems),
          _row('Customer:', user?.fullName ?? 'IAM User'),
          _row(
            'Destination:',
            order.shippingInfo?.completeAddress != null
                ? toTitleCase(order.shippingInfo!.completeAddress)
                : 'No Selected Address',
          ),
          _row('Contact No.:', order.shippingInfo?.mobileNo ?? 'N/A'),
          _row('Payment Method:', order.paymentMethod ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IAMSizes.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.45,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.55,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _timeline() {
    return FutureBuilder(
      future: ApiMiddleware.orders.getOrderHistory(order.orderRefno),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data?.data ?? [];

        if (history.isEmpty) {
          return const Center(child: Text('No tracking history available'));
        }

        // Sort so the latest status is at the end of the list
        history.sort((a, b) {
          final dateA = DateTime.tryParse(a?.tranDate ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b?.tranDate ?? '') ?? DateTime(0);
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final bool isLast = index == history.length - 1;

            // Color logic: The very last item in history is Primary, everything before is Black
            return _step(
              item?.orderStatusName ?? '',
              item?.remarks ?? '',
              isCurrent: isLast,
              isLast: isLast,
            );
          },
        );
      },
    );
  }

  Widget _step(
    String title,
    String subtitle, {
    required bool isCurrent,
    required bool isLast,
  }) {
    Color mainColor = isCurrent ? IAMColors.primary : Colors.black;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color:
                    Colors.black, // Line is always black for completed segments
              ),
          ],
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: mainColor),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrent ? IAMColors.primary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: IAMSizes.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Cancel Order'),
            ),
          ),
          const SizedBox(width: IAMSizes.spaceBtwItems),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: IAMColors.primary,
              ),
              child: const Text('Live Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
