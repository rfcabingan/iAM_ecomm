import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key, required this.referralId});

  final String referralId;

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  late Future<ApiResponse<ReferralData?>> _referralsFuture;

  @override
  void initState() {
    super.initState();
    _referralsFuture = _loadReferrals();
  }

  Future<ApiResponse<ReferralData?>> _loadReferrals() {
    final referralId = widget.referralId.trim();
    if (referralId.isEmpty) {
      return Future.value(
        const ApiResponse<ReferralData?>(
          status: 0,
          success: false,
          message: 'No referral ID available.',
        ),
      );
    }

    return ApiMiddleware.referral.getReferralById(referralId);
  }

  Future<void> _refreshReferrals() async {
    setState(() {
      _referralsFuture = _loadReferrals();
    });
    await _referralsFuture;
  }

  void _copyReferralId() {
    final referralId = widget.referralId.trim();
    if (referralId.isEmpty) return;

    Clipboard.setData(ClipboardData(text: referralId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral ID copied.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareReferralId() async {
    final referralId = widget.referralId.trim();
    if (referralId.isEmpty) return;

    await Share.share('Use my IAM Ecomm referral code: $referralId');
  }

  @override
  Widget build(BuildContext context) {
    final referralId = widget.referralId.trim();

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(
          'My Referrals',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReferrals,
        child: FutureBuilder<ApiResponse<ReferralData?>>(
          future: _referralsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final response = snapshot.data;
            final data = response?.data;

            if (response?.success != true || data == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: Center(
                      child: Text(
                        response?.message.isNotEmpty == true
                            ? response!.message
                            : 'Unable to load referrals.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final referrals = data.referrals;

            if (referrals.isEmpty) {
              return _EmptyReferralsContent(
                referralId: referralId,
                onCopy: _copyReferralId,
                onShare: _shareReferralId,
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              itemCount: referrals.length + 1,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: IAMSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ReferralSummaryCard(data: data);
                }

                return _ReferralCard(referral: referrals[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReferralSummaryCard extends StatelessWidget {
  const _ReferralSummaryCard({required this.data});

  final ReferralData data;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final countText = NumberFormat.decimalPattern().format(data.totalReferrals);

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? IAMColors.darkerGrey : const Color(0xFFF0E8D7),
        ),
        boxShadow: dark ? null : kElevationToShadow[1],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: IAMColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.profile_2user,
              color: IAMColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$countText total referrals',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  'Referral ID ${data.referralId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? Colors.white70 : IAMColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.referral});

  final ReferralItem referral;

  String get _displayName {
    final fullName = referral.fullName.trim();
    if (fullName.isNotEmpty) return fullName;

    final parts = [
      referral.firstName.trim(),
      referral.lastName.trim(),
    ].where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');

    return referral.idno.isNotEmpty ? referral.idno : 'Referral';
  }

  String get _joinedDate {
    final parsed = DateTime.tryParse(referral.createdAt);
    if (parsed == null) return '';
    return DateFormat('MMM d, yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final joinedDate = _joinedDate;

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : IAMColors.white,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? IAMColors.darkerGrey : IAMColors.borderSecondary,
        ),
        boxShadow: dark ? null : kElevationToShadow[1],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: IAMColors.primary.withValues(alpha: 0.14),
            child: Text(
              _displayName.characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: IAMColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: IAMSizes.sm),
                    _ReferralStatusChip(
                      label: referral.isVerified ? 'Verified' : 'Pending',
                      isPositive: referral.isVerified,
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.xs),
                if (referral.idno.isNotEmpty)
                  Text(
                    referral.idno,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? IAMColors.lightGrey : IAMColors.darkerGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: IAMSizes.sm),
                if (referral.email.isNotEmpty)
                  _ReferralInfoLine(icon: Iconsax.sms, text: referral.email),
                if (referral.mobileNo.isNotEmpty) ...[
                  const SizedBox(height: IAMSizes.xs),
                  _ReferralInfoLine(
                    icon: Iconsax.call,
                    text: referral.mobileNo,
                  ),
                ],
                if (joinedDate.isNotEmpty) ...[
                  const SizedBox(height: IAMSizes.xs),
                  _ReferralInfoLine(
                    icon: Iconsax.calendar_1,
                    text: 'Joined $joinedDate',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralStatusChip extends StatelessWidget {
  const _ReferralStatusChip({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? IAMColors.success : IAMColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IAMSizes.sm,
        vertical: IAMSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReferralInfoLine extends StatelessWidget {
  const _ReferralInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: dark ? Colors.white60 : IAMColors.textSecondary,
        ),
        const SizedBox(width: IAMSizes.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? Colors.white70 : IAMColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyReferralsContent extends StatelessWidget {
  const _EmptyReferralsContent({
    required this.referralId,
    required this.onCopy,
    required this.onShare,
  });

  final String referralId;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final creamCircle = dark
        ? IAMColors.primary.withValues(alpha: 0.12)
        : const Color(0xFFFFF9E5);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: IAMSizes.defaultSpace,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 288,
                  height: 264,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      _emptySparkle(right: 18, top: 26),
                      _emptySparkle(left: 2, top: 76, small: true),
                      _emptySparkle(right: 4, bottom: 86, dot: true),
                      _emptySparkle(left: 26, bottom: 94, dot: true),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: creamCircle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.profile_2user,
                          size: 100,
                          color: IAMColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                Text(
                  'No referrals yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: dark ? IAMColors.white : IAMColors.black,
                  ),
                ),
                const SizedBox(height: IAMSizes.md),
                Text(
                  'Share your referral code so new users can join through your account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark
                        ? IAMColors.white.withValues(alpha: 0.75)
                        : IAMColors.black.withValues(alpha: 0.70),
                    height: 1.45,
                  ),
                ),
                if (referralId.isNotEmpty) ...[
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCopy,
                          icon: const Icon(Iconsax.copy, size: 18),
                          label: const Text('Copy'),
                        ),
                      ),
                      const SizedBox(width: IAMSizes.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onShare,
                          icon: const Icon(Iconsax.share, size: 18),
                          label: const Text('Share Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: IAMColors.primary,
                            foregroundColor: IAMColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptySparkle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    bool small = false,
    bool dot = false,
  }) {
    final size = small ? 12.0 : 16.0;
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Icon(
        dot ? Icons.circle : Icons.add,
        size: dot ? 6 : size,
        color: IAMColors.primary.withValues(alpha: dot ? 0.45 : 0.55),
      ),
    );
  }
}
