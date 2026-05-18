import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_detail_screen.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ReferralOrderList extends StatefulWidget {
  const ReferralOrderList({super.key});

  @override
  State<ReferralOrderList> createState() => _ReferralOrderListState();
}

class _ReferralOrderListState extends State<ReferralOrderList> {
  int selectedIndex = 0;

  static const List<_ReferralOrderTab> _tabs = [
    _ReferralOrderTab(
      label: 'Pending',
      status: 'PENDING',
      emptyIcon: Iconsax.timer_1,
      emptyTitle: 'No pending referral orders',
      emptySubtitle: 'Orders from referred buyers will appear here once placed.',
    ),
    _ReferralOrderTab(
      label: 'Completed',
      status: 'COMPLETED',
      emptyIcon: Iconsax.tick_circle,
      emptyTitle: 'No completed referral orders',
      emptySubtitle: 'Completed referral-linked orders will appear here.',
    ),
    _ReferralOrderTab(
      label: 'Cancelled',
      status: 'CANCELLED',
      emptyIcon: Iconsax.close_circle,
      emptyTitle: 'No cancelled referral orders',
      emptySubtitle: 'Cancelled referral-linked orders will appear here.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(
                Icons.swipe_left_alt_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Swipe tabs to see more',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ),
              Icon(
                Icons.swipe_right_alt_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        const SizedBox(height: IAMSizes.sm),
        IAMRoundedContainer(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          backgroundColor: dark ? Colors.grey[900]! : Colors.grey[200]!,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildChip(i, _tabs[i].label),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        Expanded(
          child: IndexedStack(
            index: selectedIndex.clamp(0, _tabs.length - 1),
            children: _tabs
                .map((tab) => _ReferralOrderStatusTab(tab: tab))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(int index, String title) {
    final isSelected = selectedIndex == index;
    final bg = isSelected ? Colors.white : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralOrderStatusTab extends StatefulWidget {
  const _ReferralOrderStatusTab({required this.tab});

  final _ReferralOrderTab tab;

  @override
  State<_ReferralOrderStatusTab> createState() => _ReferralOrderStatusTabState();
}

class _ReferralOrderStatusTabState extends State<_ReferralOrderStatusTab> {
  late Future<ApiResponse<List<ReferralOrderItem?>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<ApiResponse<List<ReferralOrderItem?>>> _loadOrders() {
    return ApiMiddleware.orders.getReferralOrders(status: widget.tab.status);
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _loadOrders();
    });
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<ApiResponse<List<ReferralOrderItem?>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data;
          if (response?.success != true) {
            return _ReferralOrderMessage(
              icon: Iconsax.info_circle,
              title: 'Unable to load referral orders',
              message: response?.message ?? 'Please try again in a moment.',
            );
          }

          final orders =
              response?.data?.whereType<ReferralOrderItem>().toList() ??
              const <ReferralOrderItem>[];

          if (orders.isEmpty) {
            return _ReferralOrderMessage(
              icon: widget.tab.emptyIcon,
              title: widget.tab.emptyTitle,
              message: widget.tab.emptySubtitle,
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(IAMSizes.md),
            itemCount: orders.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: IAMSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              return _ReferralOrderCard(order: orders[index]);
            },
          );
        },
      ),
    );
  }
}

class _ReferralOrderCard extends StatelessWidget {
  const _ReferralOrderCard({required this.order});

  final ReferralOrderItem order;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: 'PHP ',
      decimalDigits: 2,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
            ),
          );
        },
        child: IAMRoundedContainer(
          padding: const EdgeInsets.all(IAMSizes.md),
          backgroundColor: dark ? IAMColors.dark : IAMColors.light,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderRefno}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.apply(fontWeightDelta: 2),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: order.orderRefno),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Order number copied!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green[300],
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.copy),
                    iconSize: IAMSizes.iconSm,
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: IAMColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.profile_2user,
                      size: 20,
                      color: IAMColors.grey,
                    ),
                  ),
                  const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.orderStatusName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .apply(
                                      color: IAMColors.primary,
                                      fontWeightDelta: 1,
                                    ),
                              ),
                            ),
                            const Tooltip(
                              message: 'View order details',
                              child: Icon(
                                Iconsax.arrow_right_3,
                                size: 18,
                                color: IAMColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buyer ${_fallbackText(order.buyerIdNo)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              _ReferralOrderInfoRow(
                icon: Iconsax.calendar,
                label: _formatOrderDate(order.orderDate),
              ),
              const SizedBox(height: IAMSizes.sm),
              _ReferralOrderInfoRow(
                icon: Iconsax.user_tick,
                label: 'Referral ID ${_fallbackText(order.referralId)}',
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Divider(color: Colors.grey[400], thickness: 1),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Text(
                    formatter.format(order.totalAmount),
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                      fontWeightDelta: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralOrderInfoRow extends StatelessWidget {
  const _ReferralOrderInfoRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: dark ? IAMColors.darkerGrey : IAMColors.lightGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: IAMColors.darkGrey),
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems / 2),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ReferralOrderMessage extends StatelessWidget {
  const _ReferralOrderMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(IAMSizes.lg),
      children: [
        const SizedBox(height: IAMSizes.spaceBtwSections * 2),
        Icon(icon, color: IAMColors.primary, size: 48),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: IAMSizes.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dark ? Colors.white70 : IAMColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _ReferralOrderTab {
  const _ReferralOrderTab({
    required this.label,
    required this.status,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String label;
  final String status;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
}

String _formatOrderDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? 'No order date' : value;
  return DateFormat('dd-MMM-yyyy, hh:mma').format(parsed);
}

String _fallbackText(String value) {
  return value.trim().isEmpty ? 'Unavailable' : value.trim();
}
