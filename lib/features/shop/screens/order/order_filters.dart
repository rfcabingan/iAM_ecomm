import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_status_ids.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// Payment status values from the Orders API.
abstract final class PaymentStatusIds {
  static const int expired = 4;
}

/// Shared order list / payment filtering helpers.
abstract final class OrderFilters {
  static bool isPaymentExpired(OrderItem order) {
    return order.paymentStatusId == PaymentStatusIds.expired ||
        order.paymentStatusName.toLowerCase().trim() == 'expired';
  }

  static bool isPaymentExpiredDetail(OrderDetailItem order) {
    return order.paymentStatusId == PaymentStatusIds.expired ||
        order.paymentStatusName.toLowerCase().trim() == 'expired';
  }

  /// Expired-payment orders are hidden from all order tabs.
  static bool shouldShowInOrderTabs(OrderItem order) =>
      !isPaymentExpired(order);

  static bool shouldShowInCancelledTab(OrderItem order) {
    if (isPaymentExpired(order)) return false;
    return _isTerminalOrder(order);
  }

  static bool _isTerminalOrder(OrderItem order) {
    const terminalIds = {
      OrderStatusIds.cancelled,
      OrderStatusIds.failedDelivery,
      OrderStatusIds.returned,
      OrderStatusIds.lostAndDamaged,
    };
    if (terminalIds.contains(order.orderStatusId)) return true;
    final n = order.orderStatusName.toLowerCase().trim();
    return n.contains('cancel') ||
        n.contains('failed') ||
        n.contains('return') ||
        n.contains('lost') ||
        n.contains('damaged');
  }

  static DateTime? parseOrderDate(String orderDate) {
    if (orderDate.trim().isEmpty) return null;
    return DateTime.tryParse(orderDate);
  }

  static bool matchesDateRange(
    OrderItem order, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) return true;
    final parsed = parseOrderDate(order.orderDate);
    if (parsed == null) return true;
    final orderDay = DateTime(parsed.year, parsed.month, parsed.day);
    if (startDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      if (orderDay.isBefore(start)) return false;
    }
    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      if (orderDay.isAfter(end)) return false;
    }
    return true;
  }
}

/// Active date range filter for order tabs (client-side).
class OrderListFilters {
  const OrderListFilters({this.startDate, this.endDate});

  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasActiveFilter => startDate != null || endDate != null;

  bool matches(OrderItem order) =>
      OrderFilters.shouldShowInOrderTabs(order) &&
      OrderFilters.matchesDateRange(
        order,
        startDate: startDate,
        endDate: endDate,
      );

}

class OrderListFilterScope extends InheritedWidget {
  const OrderListFilterScope({
    super.key,
    required this.filters,
    required super.child,
  });

  final OrderListFilters filters;

  static OrderListFilters of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<OrderListFilterScope>();
    return scope?.filters ?? const OrderListFilters();
  }

  @override
  bool updateShouldNotify(OrderListFilterScope oldWidget) {
    return oldWidget.filters.startDate != filters.startDate ||
        oldWidget.filters.endDate != filters.endDate;
  }
}

Future<OrderListFilters?> showOrderDateFilterSheet(
  BuildContext context, {
  required OrderListFilters initial,
}) {
  return showModalBottomSheet<OrderListFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _OrderDateFilterSheet(initial: initial),
  );
}

class _OrderDateFilterSheet extends StatefulWidget {
  const _OrderDateFilterSheet({required this.initial});

  final OrderListFilters initial;

  @override
  State<_OrderDateFilterSheet> createState() => _OrderDateFilterSheetState();
}

class _OrderDateFilterSheetState extends State<_OrderDateFilterSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;

  static final _dateLabelFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initial.startDate;
    _endDate = widget.initial.endDate;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: IAMColors.primary,
              onPrimary: IAMColors.black,
              surface: IAMColors.white,
              onSurface: IAMColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && picked.isBefore(_startDate!)) {
          _startDate = picked;
        }
      }
    });
  }

  String _formatDate(DateTime? date) =>
      date == null ? 'Select date' : _dateLabelFormat.format(date);

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? IAMColors.dark : IAMColors.white;
    final border = dark ? IAMColors.darkerGrey : const Color(0xFFF1E8D2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          IAMSizes.md,
          0,
          IAMSizes.md,
          IAMSizes.md,
        ),
        child: Container(
          padding: const EdgeInsets.all(IAMSizes.lg),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: IAMColors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: IAMColors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.md),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Iconsax.calendar_1,
                      color: IAMColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: IAMSizes.sm),
                  Expanded(
                    child: Text(
                      'Filter by date',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.xs),
              Text(
                'Show orders placed within your selected range. Leave blank to see all.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: IAMColors.darkGrey,
                ),
              ),
              const SizedBox(height: IAMSizes.lg),
              _DateField(
                label: 'From',
                value: _formatDate(_startDate),
                onTap: () => _pickDate(isStart: true),
                onClear: _startDate == null
                    ? null
                    : () => setState(() => _startDate = null),
              ),
              const SizedBox(height: IAMSizes.sm),
              _DateField(
                label: 'To',
                value: _formatDate(_endDate),
                onTap: () => _pickDate(isStart: false),
                onClear: _endDate == null
                    ? null
                    : () => setState(() => _endDate = null),
              ),
              const SizedBox(height: IAMSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, const OrderListFilters()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: IAMColors.primary,
                        side: const BorderSide(color: IAMColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: IAMSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        OrderListFilters(
                          startDate: _startDate,
                          endDate: _endDate,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IAMColors.primary,
                        foregroundColor: IAMColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return IAMRoundedContainer(
      showBorder: true,
      borderColor: IAMColors.primary.withValues(alpha: 0.35),
      backgroundColor: dark ? IAMColors.black : IAMColors.accent.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(
        horizontal: IAMSizes.md,
        vertical: IAMSizes.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: IAMColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Iconsax.close_circle, size: 20),
              color: IAMColors.darkGrey,
              tooltip: 'Clear',
            ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Iconsax.calendar, color: IAMColors.primary),
          ),
        ],
      ),
    );
  }
}
