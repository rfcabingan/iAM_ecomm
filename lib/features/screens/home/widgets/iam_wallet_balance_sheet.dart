import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

void showIamWalletBalanceQuickSheet(BuildContext context) {
  final loggedIn =
      Get.isRegistered<AuthController>() &&
      AuthController.instance.isLoggedIn.value;
  if (!loggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Sign in to view your wallet balance.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _IamWalletBalanceQuickSheet(),
  );
}

class _IamWalletBalanceQuickSheet extends StatefulWidget {
  const _IamWalletBalanceQuickSheet();

  @override
  State<_IamWalletBalanceQuickSheet> createState() =>
      _IamWalletBalanceQuickSheetState();
}

class _IamWalletBalanceQuickSheetState
    extends State<_IamWalletBalanceQuickSheet> {
  WalletBalanceData? _data;
  PointsBalanceData? _pointsData;
  bool _loading = true;
  String? _pointsError;
  String? _error;

  bool get _canShowPoints =>
      Get.isRegistered<AuthController>() &&
      (AuthController.instance.isMember || AuthController.instance.isGuest);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final canShowPoints = _canShowPoints;
    final walletFuture = ApiMiddleware.wallet.getBalance();
    final pointsFuture = canShowPoints
        ? ApiMiddleware.points.getBalance()
        : null;

    final res = await walletFuture;
    final pointsRes = pointsFuture == null ? null : await pointsFuture;

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success && res.data != null) {
        _data = res.data;
        _error = null;
      } else {
        _data = null;
        _error = res.message.isNotEmpty
            ? res.message
            : 'Unable to load wallet balance.';
      }

      if (canShowPoints) {
        if (pointsRes?.success == true && pointsRes?.data != null) {
          _pointsData = pointsRes!.data;
          _pointsError = null;
        } else {
          _pointsData = null;
          _pointsError = pointsRes?.message.isNotEmpty == true
              ? pointsRes!.message
              : 'Unable to load points.';
        }
      } else {
        _pointsData = null;
        _pointsError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.7 : 0.62);
    final canShowPoints = _canShowPoints;

    return FractionallySizedBox(
      heightFactor: canShowPoints ? 0.54 : 0.42,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: IAMColors.primary.withOpacity(
                          dark ? 0.22 : 0.16,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: IAMColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Image.asset(
                        IAMImages.walletIcon,
                        fit: BoxFit.contain,
                        semanticLabel: 'IAM Wallet',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IAM Wallet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                          ),
                          Text(
                            'Available Balance:',
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    0,
                    IAMSizes.defaultSpace,
                    IAMSizes.defaultSpace,
                  ),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: IAMColors.error, height: 1.3),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              IAMRoundedContainer(
                              showBorder: true,
                              padding: const EdgeInsets.all(IAMSizes.lg),
                              backgroundColor: dark
                                  ? IAMColors.black
                                  : IAMColors.lightGrey,
                              borderColor: onSurface.withOpacity(0.1),
                              child: Column(
                                children: [
                                  Text(
                                    IAMFormatter.formatCurrency(
                                      (_data?.balance ?? 0).toDouble(),
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: IAMColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Account ${_data?.accountId ?? '—'}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: muted),
                                  ),
                                ],
                              ),
                            ),
                            if (canShowPoints) ...[
                              const SizedBox(height: IAMSizes.md),
                              _PointsBalanceCard(
                                points: _pointsData,
                                error: _pointsError,
                                dark: dark,
                                muted: muted,
                                onSurface: onSurface,
                              ),
                            ],
                            const SizedBox(height: IAMSizes.md),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _loading = true;
                                    _error = null;
                                    _pointsData = null;
                                    _pointsError = null;
                                  });
                                  _load();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: onSurface,
                                  side: BorderSide(
                                    color: onSurface.withOpacity(0.2),
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Refresh'),
                              ),
                            ),
                            ],
                          ),
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

class _PointsBalanceCard extends StatelessWidget {
  const _PointsBalanceCard({
    required this.points,
    required this.error,
    required this.dark,
    required this.muted,
    required this.onSurface,
  });

  final PointsBalanceData? points;
  final String? error;
  final bool dark;
  final Color muted;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    final total = points?.totalPoints;

    return IAMRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: dark ? IAMColors.black : IAMColors.lightGrey,
      borderColor: onSurface.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: IAMColors.primary.withOpacity(dark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: IAMColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: IAMSizes.sm),
              Expanded(
                child: Text(
                  'Total Points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                total == null
                    ? '-- pts'
                    : '${IAMFormatter.formatAccountingAmount(total.toDouble())} pts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: IAMColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: IAMSizes.xs),
            Text(
              error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: IAMColors.error,
                height: 1.25,
              ),
            ),
          ] else if (points != null) ...[
            const SizedBox(height: IAMSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _PointStat(
                    label: 'Earned',
                    value: points!.earnedPoints,
                    muted: muted,
                    onSurface: onSurface,
                  ),
                ),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: _PointStat(
                    label: 'Redeemed',
                    value: points!.redeemedPoints,
                    muted: muted,
                    onSurface: onSurface,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PointStat extends StatelessWidget {
  const _PointStat({
    required this.label,
    required this.value,
    required this.muted,
    required this.onSurface,
  });

  final String label;
  final num value;
  final Color muted;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.sm),
      decoration: BoxDecoration(
        color: onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 2),
          Text(
            '${IAMFormatter.formatAccountingAmount(value.toDouble())} pts',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
