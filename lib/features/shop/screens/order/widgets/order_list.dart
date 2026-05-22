import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_filters.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_status_ids.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/cancelled_order_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/delivered_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/processing_order_screen.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class IAMOrderListItems extends StatefulWidget {
  const IAMOrderListItems({super.key, required this.filters});

  final OrderListFilters filters;

  @override
  State<IAMOrderListItems> createState() => _IAMOrderListItemsState();
}

class _IAMOrderListItemsState extends State<IAMOrderListItems> {
  int selectedIndex = 0;

  static final List<(String label, Widget page)> _tabs = [
    (
      'Pending',
      PipelineStageTab(
        stageIds: const {OrderStatusIds.pending},
        emptyIcon: Iconsax.timer_1,
        emptyTitle: 'No pending orders',
        emptySubtitle: 'Once you place an order, it will show up here.',
      ),
    ),
    (
      'Ready',
      PipelineStageTab(
        stageIds: const {OrderStatusIds.readyToShip},
        emptyIcon: Iconsax.box,
        emptyTitle: 'No orders ready to ship',
        emptySubtitle: 'We’ll show your orders here when they are packed and ready.',
      ),
    ),
    (
      'Transit',
      PipelineStageTab(
        stageIds: const {OrderStatusIds.inTransit},
        emptyIcon: Iconsax.truck_fast,
        emptyTitle: 'No orders in transit',
        emptySubtitle: 'Orders that are on the way will appear here.',
      ),
    ),
    ('Delivered', const DeliveredTab()),
    ('Cancelled', const CancelledTab()),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final filters = widget.filters;

    return OrderListFilterScope(
      filters: filters,
      child: Column(
      children: [
        if (filters.hasActiveFilter) ...[
          IAMRoundedContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: IAMSizes.md,
              vertical: IAMSizes.sm,
            ),
            backgroundColor: IAMColors.primary.withValues(alpha: 0.12),
            showBorder: true,
            borderColor: IAMColors.primary.withValues(alpha: 0.35),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 18, color: IAMColors.primary),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: Text(
                    _filterSummary(filters),
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? IAMColors.white : IAMColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: IAMSizes.sm),
        ],
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
                    child: _buildChip(i, _tabs[i].$1),
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
            children: _tabs.map((t) => t.$2).toList(),
          ),
        ),
      ],
    ),
    );
  }

  String _filterSummary(OrderListFilters filters) {
    final fmt = DateFormat('dd MMM yyyy');
    if (filters.startDate != null && filters.endDate != null) {
      return 'Showing orders from ${fmt.format(filters.startDate!)} to ${fmt.format(filters.endDate!)}';
    }
    if (filters.startDate != null) {
      return 'Showing orders from ${fmt.format(filters.startDate!)}';
    }
    if (filters.endDate != null) {
      return 'Showing orders until ${fmt.format(filters.endDate!)}';
    }
    return '';
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
