import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';

void showIamPointsSummarySheet(
  BuildContext context, {
  PointsBalanceData? balance,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _IamPointsSummarySheet(balance: balance),
  );
}

class _IamPointsSummarySheet extends StatefulWidget {
  const _IamPointsSummarySheet({this.balance});

  final PointsBalanceData? balance;

  @override
  State<_IamPointsSummarySheet> createState() => _IamPointsSummarySheetState();
}

class _IamPointsSummarySheetState extends State<_IamPointsSummarySheet> {
  late Future<ApiResponse<List<PointsHistoryItem>?>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiMiddleware.points.getPoints();
  }

  void _refresh() {
    setState(() {
      _historyFuture = ApiMiddleware.points.getPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.7 : 0.62);
    final balance = widget.balance;

    return FractionallySizedBox(
      heightFactor: 0.88,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.45 : 0.18),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(dark ? 0.2 : 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IAMSizes.defaultSpace,
                  14,
                  IAMSizes.sm,
                  IAMSizes.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: IAMColors.primary.withOpacity(dark ? 0.22 : 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: IAMColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: IAMColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Points Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: onSurface,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (balance != null && balance.accountId.isNotEmpty)
                            Text(
                              'Account ${balance.accountId}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            )
                          else
                            Text(
                              'Points earned and redeemed from your orders',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _refresh,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: onSurface.withOpacity(0.75),
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
              if (balance != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IAMSizes.defaultSpace,
                  ),
                  child: IAMRoundedContainer(
                    showBorder: true,
                    padding: const EdgeInsets.all(IAMSizes.md),
                    backgroundColor: dark ? IAMColors.black : IAMColors.lightGrey,
                    borderColor: onSurface.withOpacity(0.1),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: 'Total',
                            value: balance.totalPoints,
                            highlight: true,
                            muted: muted,
                            onSurface: onSurface,
                          ),
                        ),
                        const SizedBox(width: IAMSizes.sm),
                        Expanded(
                          child: _SummaryStat(
                            label: 'Earned',
                            value: balance.earnedPoints,
                            muted: muted,
                            onSurface: onSurface,
                          ),
                        ),
                        const SizedBox(width: IAMSizes.sm),
                        Expanded(
                          child: _SummaryStat(
                            label: 'Redeemed',
                            value: balance.redeemedPoints,
                            muted: muted,
                            onSurface: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: IAMSizes.md),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.defaultSpace,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    0,
                    IAMSizes.defaultSpace,
                    IAMSizes.defaultSpace,
                  ),
                  child: _PointsHistoryList(
                    future: _historyFuture,
                    dark: dark,
                    onSurface: onSurface,
                    muted: muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.muted,
    required this.onSurface,
    this.highlight = false,
  });

  final String label;
  final num value;
  final Color muted;
  final Color onSurface;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 2),
        Text(
          '${IAMFormatter.formatAccountingAmount(value.toDouble())} pts',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: highlight ? IAMColors.primary : onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PointsHistoryList extends StatelessWidget {
  const _PointsHistoryList({
    required this.future,
    required this.dark,
    required this.onSurface,
    required this.muted,
  });

  final Future<ApiResponse<List<PointsHistoryItem>?>> future;
  final bool dark;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<PointsHistoryItem>?>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final response = snapshot.data;
        final items =
            response?.data?.whereType<PointsHistoryItem>().toList() ??
            const <PointsHistoryItem>[];

        if (response?.success != true) {
          return _PointsHistoryState(
            icon: Icons.info_outline_rounded,
            message: response?.message.isNotEmpty == true
                ? response!.message
                : 'Unable to load points history.',
            muted: muted,
          );
        }

        if (items.isEmpty) {
          return _PointsHistoryState(
            icon: Icons.receipt_long_outlined,
            message: 'No points transactions found yet.',
            muted: muted,
          );
        }

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: IAMSizes.sm),
          itemBuilder: (context, index) {
            return _PointsHistoryTile(
              item: items[index],
              dark: dark,
              onSurface: onSurface,
              muted: muted,
            );
          },
        );
      },
    );
  }
}

class _PointsHistoryTile extends StatelessWidget {
  const _PointsHistoryTile({
    required this.item,
    required this.dark,
    required this.onSurface,
    required this.muted,
  });

  final PointsHistoryItem item;
  final bool dark;
  final Color onSurface;
  final Color muted;

  String get _orderRef {
    if (item.ptsRefNo.isNotEmpty) return item.ptsRefNo;
    if (item.relatedTranNo != null && item.relatedTranNo!.isNotEmpty) {
      return item.relatedTranNo!;
    }
    return 'No order reference';
  }

  String get _title {
    if (item.tranDesc.isNotEmpty) return item.tranDesc;
    if (item.sourceApp.isNotEmpty) return item.sourceApp;
    return 'Points transaction';
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatPointsDate(item.tranDate);
    final pts = item.pts;
    final isEarned = pts > 0;
    final isRedeemed = pts < 0;
    final ptsColor = isEarned
        ? IAMColors.primary
        : isRedeemed
        ? IAMColors.error
        : onSurface;
    final ptsPrefix = isEarned ? '+' : '';
    final typeLabel = isEarned
        ? 'Earned'
        : isRedeemed
        ? 'Redeemed'
        : 'Adjusted';

    return IAMRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: dark ? IAMColors.black : IAMColors.lightGrey,
      borderColor: onSurface.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IAMColors.primary.withOpacity(dark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEarned
                  ? Icons.add_circle_outline_rounded
                  : isRedeemed
                  ? Icons.remove_circle_outline_rounded
                  : Icons.swap_horiz_rounded,
              color: ptsColor,
              size: 20,
            ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orderRef,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  _title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  '$date · $typeLabel · Bal ${IAMFormatter.formatAccountingAmount(item.runningBalance.toDouble())}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: muted.withOpacity(0.85),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: IAMSizes.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              '$ptsPrefix${IAMFormatter.formatAccountingAmount(pts.abs().toDouble())} pts',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ptsColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsHistoryState extends StatelessWidget {
  const _PointsHistoryState({
    required this.icon,
    required this.message,
    required this.muted,
  });

  final IconData icon;
  final String message;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IAMSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: IAMColors.primary, size: 32),
            const SizedBox(height: IAMSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: muted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPointsDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? 'No date' : value;
  return DateFormat('MMM d, yyyy').format(parsed);
}
