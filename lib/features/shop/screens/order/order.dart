import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_filters.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_list.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderListFilters _filters = const OrderListFilters();

  Future<void> _openDateFilter() async {
    final result = await showOrderDateFilterSheet(
      context,
      initial: _filters,
    );
    if (!mounted || result == null) return;
    setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        showBackArrow: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _openDateFilter,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : IAMColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filters.hasActiveFilter
                        ? IAMColors.primary
                        : IAMColors.primary.withValues(alpha: 0.3),
                    width: _filters.hasActiveFilter ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.filter,
                      size: 16,
                      color: _filters.hasActiveFilter
                          ? IAMColors.primary
                          : IAMColors.darkGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _filters.hasActiveFilter ? 'Filtered' : 'Filter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _filters.hasActiveFilter
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: _filters.hasActiveFilter
                            ? IAMColors.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Swipe left or right on the tabs to view more order statuses.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: IAMColors.primary,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : IAMColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: IAMColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text('Info', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(IAMSizes.defaultSpace),
        child: IAMOrderListItems(filters: _filters),
      ),
    );
  }
}
