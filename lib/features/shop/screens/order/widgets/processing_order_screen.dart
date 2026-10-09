import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/payments/checkout_webview_sheet.dart';
import 'package:iam_ecomm/common/widgets/payments/iam_wallet_pay_sheet.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_detail_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_filters.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_status_ids.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_empty_state.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_list_card.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// Orders shown while moving toward delivery (positive pipeline). Filter by [`OrderStatusIds`].
class PipelineStageTab extends StatefulWidget {
  const PipelineStageTab({
    super.key,
    required this.stageIds,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    this.emptyFooter,
  });

  final Set<int> stageIds;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final Widget? emptyFooter;

  @override
  State<PipelineStageTab> createState() => _PipelineStageTabState();
}

bool _orderMatchesPipelineStage(OrderItem order, Set<int> stageIds) {
  if (stageIds.contains(order.orderStatusId)) return true;
  final n = order.orderStatusName.toLowerCase().trim();
  if (stageIds.contains(OrderStatusIds.pending) &&
      (n == 'pending' || n.startsWith('pending'))) {
    return true;
  }
  if (stageIds.contains(OrderStatusIds.verified) && n.contains('verified')) {
    return true;
  }
  if (stageIds.contains(OrderStatusIds.readyToShip) &&
      (n.contains('ready') && (n.contains('ship') || n.contains('pickup')))) {
    return true;
  }
  if (stageIds.contains(OrderStatusIds.inTransit) &&
      (n.contains('transit') ||
          (n.contains('shipped') && !n.contains('ready')) ||
          n.contains('on the way'))) {
    return true;
  }
  return false;
}

class _PipelineStageTabState extends State<PipelineStageTab> {
  Future<ApiResponse<List<OrderItem?>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiMiddleware.orders.getOrders();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = ApiMiddleware.orders.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return FutureBuilder(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          return const Center(child: Text('No orders found'));
        }

        final dateFilters = OrderListFilterScope.of(context);
        final List<OrderItem?> orders = (snapshot.data!.data ?? [])
            .where((order) {
              final o = order;
              return o != null &&
                  _orderMatchesPipelineStage(o, widget.stageIds) &&
                  dateFilters.matches(o);
            })
            .toList();

        if (orders.isEmpty) {
          return IAMOrderEmptyState(
            icon: widget.emptyIcon,
            title: widget.emptyTitle,
            subtitle: widget.emptySubtitle,
            footer: widget.emptyFooter,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: orders.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final order = orders[index];
            if (order == null) return const SizedBox.shrink();

            return _orderCard(context, order, formatter, dark);
          },
        );
      },
    );
  }

  Widget _orderCard(
    BuildContext context,
    OrderItem order,
    NumberFormat formatter,
    bool dark,
  ) {
    return OrderListCard(
      order: order,
      formatter: formatter,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
          ),
        );
      },
      onPayNow: () async {
        final didPay = await _showPayNowFlow(context, order, formatter);
        if (!context.mounted) return false;
        if (didPay) _refresh();
        return didPay;
      },
    );
  }

  Future<bool> _showPayNowFlow(
    BuildContext context,
    OrderItem order,
    NumberFormat formatter,
  ) async {
    final provider = order.paymentProvider.trim().toUpperCase();
    final orderRef = order.orderRefno;
    final amount = order.totalAmount;

    final allowed = <_PayProviderOption>[
      if (provider == 'PAYMAYA')
        const _PayProviderOption.paymaya()
      else ...[
        const _PayProviderOption.wallet(),
        const _PayProviderOption.paymaya(),
      ],
    ];

    final selected = allowed.length == 1
        ? allowed.first
        : await showModalBottomSheet<_PayProviderOption>(
            context: context,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => _PayNowProviderSheet(
              orderRef: orderRef,
              amountText: formatter.format(amount),
              options: allowed,
            ),
          );

    if (selected == null) return false;

    if (selected.type == _PayProviderType.wallet) {
      final paid = await showIamWalletPaySheet(
        context: context,
        orderRef: orderRef,
        totalAmount: amount,
      );
      if (!context.mounted) return false;
      if (paid) {
        _redirectToHomeWithPaymentToast(
          isSuccess: true,
          message: 'Wallet payment successful.',
        );
      } else {
        _redirectToHomeWithPaymentToast(
          isSuccess: false,
          message:
              'Payment was not completed. You can try again from My Orders.',
        );
      }
      return paid;
    }

    final memberRes = await ApiMiddleware.member.getMember();
    if (!context.mounted) return false;
    final idno = memberRes.data?.idno ?? '';
    if (!memberRes.success || idno.isEmpty) {
      _showPayMayaResultScreen(
        isSuccess: false,
        orderRef: orderRef,
        amount: amount,
        message: memberRes.message.isNotEmpty
            ? memberRes.message
            : 'Unable to load your profile for payment.',
      );
      return false;
    }

    final paymentRes = await ApiMiddleware.payment.createPayment(
      orderNo: orderRef,
      idno: idno,
      amount: amount,
      currency: 'PHP',
      paymentProvider: 'PAYMAYA',
      paymentMethod: 'PAYMAYA',
      description: 'Order payment',
      clientReferenceNo: orderRef,
    );

    if (!context.mounted) return false;

    if (!paymentRes.success) {
      _showPayMayaResultScreen(
        isSuccess: false,
        orderRef: orderRef,
        amount: amount,
        message: paymentRes.message.isNotEmpty
            ? paymentRes.message
            : 'Unable to start PayMaya checkout.',
      );
      return false;
    }

    final checkoutUrl = paymentRes.data?.checkoutUrl ?? '';
    if (checkoutUrl.isEmpty) {
      _showPayMayaResultScreen(
        isSuccess: false,
        orderRef: orderRef,
        amount: amount,
        message: 'No checkout URL returned.',
      );
      return false;
    }

    final paid = await showCheckoutWebViewSheet(
      context: context,
      checkoutUrl: checkoutUrl,
      orderRef: orderRef,
      totalAmount: amount,
    );
    final result = await _resolvePayMayaPaymentResult(
      orderRef: orderRef,
      webViewPaid: paid,
    );
    _showPayMayaResultScreen(
      isSuccess: result.isSuccess,
      orderRef: orderRef,
      amount: amount,
      message: result.message,
    );
    return result.isSuccess;
  }

  Future<_PayMayaPaymentResult> _resolvePayMayaPaymentResult({
    required String orderRef,
    required bool webViewPaid,
  }) async {
    if (webViewPaid) {
      return const _PayMayaPaymentResult(
        isSuccess: true,
        message: 'Your Maya payment was completed successfully.',
      );
    }

    final statusRes = await ApiMiddleware.payment.getPaymentStatus(orderRef);
    final statusMessage = _paymentStatusMessage(statusRes.data);
    final message = statusMessage.isNotEmpty ? statusMessage : statusRes.message;

    if (statusRes.success && _paymentStatusLooksPaid(statusRes.data)) {
      return _PayMayaPaymentResult(
        isSuccess: true,
        message: message.isNotEmpty
            ? message
            : 'Your Maya payment was completed successfully.',
      );
    }

    return _PayMayaPaymentResult(
      isSuccess: false,
      message: message.isNotEmpty
          ? message
          : 'Payment was not completed. You can try again from My Orders.',
    );
  }

  bool _paymentStatusLooksPaid(dynamic value) {
    if (value is Map) {
      final text = _paymentStatusText(value);
      if (_statusTextLooksUnpaid(text)) return false;
      if (_statusTextLooksPaid(text)) return true;

      final statusId = value['paymentStatusId'] ?? value['statusId'];
      if (statusId is num && statusId == PaymentStatusIds.paid) return true;
      if (statusId is String) {
        final parsedStatusId = int.tryParse(statusId);
        if (parsedStatusId != null && parsedStatusId == PaymentStatusIds.paid) return true;
      }

      return value.entries
          .where((entry) => entry.key.toString().toLowerCase() != 'message')
          .map((entry) => entry.value)
          .any(_paymentStatusLooksPaid);
    }

    if (value is List) {
      return value.any(_paymentStatusLooksPaid);
    }

    if (value is String) {
      return !_statusTextLooksUnpaid(value) && _statusTextLooksPaid(value);
    }
    return false;
  }

  String _paymentStatusMessage(dynamic value) {
    if (value is Map) {
      for (final key in const [
        'paymentStatusMessage',
        'statusMessage',
        'message',
        'paymentStatusName',
        'status',
      ]) {
        final raw = value[key];
        if (raw is String && raw.trim().isNotEmpty) return raw.trim();
      }
    }
    return '';
  }

  String _paymentStatusText(Map<dynamic, dynamic> value) {
    return [
      value['paymentStatusName'],
      value['paymentStatusMessage'],
      value['statusMessage'],
      value['status'],
    ].whereType<String>().join(' ');
  }

  bool _statusTextLooksPaid(String value) {
    final status = value.toLowerCase();
    return status.contains('paid') ||
        status.contains('success') ||
        status.contains('completed') ||
        status.contains('approved');
  }

  bool _statusTextLooksUnpaid(String value) {
    final status = value.toLowerCase();
    return status.contains('not paid') ||
        status.contains('not completed') ||
        status.contains('unpaid') ||
        status.contains('incomplete') ||
        status.contains('pending') ||
        status.contains('fail') ||
        status.contains('error') ||
        status.contains('cancel') ||
        status.contains('declin') ||
        status.contains('expired');
  }

  void _showPayMayaResultScreen({
    required bool isSuccess,
    required String orderRef,
    required num amount,
    required String message,
  }) {
    final amountText = NumberFormat.currency(
      locale: 'en_PH',
      symbol: 'PHP ',
    ).format(amount);
    final orderLine = orderRef.isNotEmpty
        ? 'Order $orderRef - $amountText'
        : amountText;
    Get.offAll(
      () => SuccessScreen(
        image: isSuccess
            ? IAMImages.successfulPaymentIcon
            : IAMImages.failPaymentIcon,
        title: isSuccess ? 'Payment Successful!' : 'Payment Not Completed',
        subTitle: '$message\n\n$orderLine',
        onPressed: _redirectToHome,
      ),
    );
  }

  void _redirectToHome() {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    navController.selectedIndex.value = 0;
    navController.storeInitialTabIndex.value = 0;
    Get.offAll(() => const NavigationMenu());
  }

  void _redirectToHomeWithPaymentToast({
    required bool isSuccess,
    required String message,
  }) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    navController.selectedIndex.value = 0;
    navController.storeInitialTabIndex.value = 0;
    Get.offAll(() => const NavigationMenu());

    void showOnReady([int attempts = 0]) {
      final currentContext = Get.context;
      if (currentContext == null) {
        if (attempts < 10) {
          Future.delayed(
            const Duration(milliseconds: 120),
            () => showOnReady(attempts + 1),
          );
        }
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(currentContext);
      if (messenger == null) {
        if (attempts < 10) {
          Future.delayed(
            const Duration(milliseconds: 120),
            () => showOnReady(attempts + 1),
          );
        }
        return;
      }
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: isSuccess ? Colors.green[300] : Colors.red.shade300,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => showOnReady());
  }
}

class _PayMayaPaymentResult {
  const _PayMayaPaymentResult({
    required this.isSuccess,
    required this.message,
  });

  final bool isSuccess;
  final String message;
}

enum _PayProviderType { wallet, paymaya }

class _PayProviderOption {
  final _PayProviderType type;
  final String title;
  final String code;
  final String iconAsset;

  const _PayProviderOption._({
    required this.type,
    required this.title,
    required this.code,
    required this.iconAsset,
  });

  const _PayProviderOption.wallet()
    : this._(
        type: _PayProviderType.wallet,
        title: 'IAM Wallet',
        code: 'IAMWALLET',
        iconAsset: IAMImages.walletIcon,
      );

  const _PayProviderOption.paymaya()
    : this._(
        type: _PayProviderType.paymaya,
        title: 'PayMaya',
        code: 'PAYMAYA',
        iconAsset: IAMImages.maya,
      );
}

class _PayNowProviderSheet extends StatelessWidget {
  const _PayNowProviderSheet({
    required this.orderRef,
    required this.amountText,
    required this.options,
  });

  final String orderRef;
  final String amountText;
  final List<_PayProviderOption> options;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.62);

    return FractionallySizedBox(
      heightFactor: options.length > 1 ? 0.62 : 0.5,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Container(
          color: surface,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(dark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IAMSizes.defaultSpace,
                  14,
                  IAMSizes.sm,
                  6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay now',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order $orderRef · $amountText',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    10,
                    IAMSizes.defaultSpace,
                    IAMSizes.defaultSpace,
                  ),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final opt = options[idx];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).pop(opt),
                        child: IAMRoundedContainer(
                          showBorder: true,
                          backgroundColor: dark
                              ? IAMColors.black
                              : IAMColors.lightGrey,
                          borderColor: onSurface.withOpacity(dark ? 0.16 : 0.1),
                          padding: const EdgeInsets.all(IAMSizes.md),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: IAMColors.primary.withOpacity(
                                    dark ? 0.18 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: IAMColors.primary.withOpacity(
                                      dark ? 0.28 : 0.22,
                                    ),
                                  ),
                                ),
                                child: Image.asset(
                                  opt.iconAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.code,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: muted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: onSurface.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
