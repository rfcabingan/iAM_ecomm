import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:iam_ecomm/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/personalization/screens/help_center/help_center.dart';
import 'package:iam_ecomm/features/personalization/screens/referral_orders/referral_orders.dart';
import 'package:iam_ecomm/features/personalization/screens/referrals/referrals.dart';
import 'package:iam_ecomm/utils/theme/theme_controller.dart';
import 'package:iam_ecomm/features/personalization/screens/address/address.dart';
import 'package:iam_ecomm/features/personalization/screens/profile/profile.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/order/order.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late Future<ApiResponse<EcomSalesCommissionTotalData?>> _ecomSalesFuture;
  late Future<ApiResponse<ReferralData?>> _referralsFuture;

  @override
  void initState() {
    super.initState();
    _ecomSalesFuture = _loadEcomSales();
    _referralsFuture = _loadReferrals();
  }

  Future<void> _refreshEcomSales() async {
    setState(() {
      _ecomSalesFuture = _loadEcomSales();
      _referralsFuture = _loadReferrals();
    });
    if (_canUseMemberFeatures) {
      await Future.wait([_ecomSalesFuture, _referralsFuture]);
    }
  }

  String get _referralId =>
      AuthController.instance.user.value?.idno.trim() ?? '';

  bool get _canUseMemberFeatures => AuthController.instance.isMember;

  bool get _canUseReferralFeatures => _canUseMemberFeatures;

  Future<ApiResponse<EcomSalesCommissionTotalData?>> _loadEcomSales() {
    if (!_canUseMemberFeatures) {
      return Future.value(
        const ApiResponse<EcomSalesCommissionTotalData?>(
          status: 0,
          success: false,
          message: 'Ecom Sales are only available for members.',
        ),
      );
    }

    return ApiMiddleware.commissions.getEcomSalesTotal();
  }

  Future<ApiResponse<ReferralData?>> _loadReferrals() {
    if (!_canUseReferralFeatures) {
      return Future.value(
        const ApiResponse<ReferralData?>(
          status: 0,
          success: false,
          message: 'Referral features are only available for members.',
        ),
      );
    }

    final referralId = _referralId;
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

  void _openReferrals() {
    if (!_canUseReferralFeatures) {
      _showMessage('Referral features are only available for members.');
      return;
    }

    final referralId = _referralId;
    if (referralId.isEmpty) {
      _showMessage('No referral ID available.');
      return;
    }

    Get.to(() => ReferralsScreen(referralId: referralId));
  }

  void _showReferralIdSheet() {
    if (!_canUseReferralFeatures) {
      _showMessage('Referral features are only available for members.');
      return;
    }

    final referralId = _referralId;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReferralIdSheet(
        referralId: referralId,
        onCopy: () => _copyReferralId(referralId),
        onShare: () => _shareReferralId(referralId),
      ),
    );
  }

  void _copyReferralId(String referralId) {
    if (referralId.isEmpty) {
      _showMessage('No referral ID available.');
      return;
    }

    Clipboard.setData(ClipboardData(text: referralId));
    _showMessage('Referral ID copied.');
  }

  Future<void> _shareReferralId(String referralId) async {
    if (referralId.isEmpty) {
      _showMessage('No referral ID available.');
      return;
    }

    await Share.share('Use my IAM Ecomm referral code: $referralId');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshEcomSales,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              //HEADER
              IAMPrimaryHeaderContainer(
                child: Column(
                  children: [
                    IAMAppBar(
                      title: Text(
                        'Account',
                        style: Theme.of(context).textTheme.headlineMedium!
                            .apply(color: IAMColors.white),
                      ),
                    ),

                    //user profile card
                    IAMUserProfile(
                      onPressed: () => Get.to(() => const ProfileScreen()),
                    ),
                    if (_canUseMemberFeatures)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: IAMSizes.defaultSpace,
                        ),
                        child: _EcomSalesSummaryView(
                          ecomSalesFuture: _ecomSalesFuture,
                          referralsFuture: _referralsFuture,
                          onReferralTap: _openReferrals,
                          showReferralMetric: _canUseReferralFeatures,
                        ),
                      ),
                    const SizedBox(height: IAMSizes.spaceBtwSections),
                  ],
                ),
              ),

              //body
              Padding(
                padding: EdgeInsets.all(IAMSizes.defaultSpace),
                child: Column(
                  children: [
                    //  ACCOUNT SETTIGNS
                    IAMSectionHeading(
                      title: 'Account Settings',
                      showActionButton: false,
                    ),
                    SizedBox(height: IAMSizes.spaceBtwItems),

                    if (_canUseReferralFeatures) ...[
                      IAMSettingMenu(
                        icon: Iconsax.ticket_star,
                        title: 'My Referral ID',
                        subTitle: 'Show and share your referral code',
                        onTap: _showReferralIdSheet,
                      ),
                      FutureBuilder<ApiResponse<ReferralData?>>(
                        future: _referralsFuture,
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data;
                          final count = data?.totalReferrals;
                          final success =
                              snapshot.data?.success == true && data != null;
                          final subTitle = !success
                              ? 'View users who used your referral code'
                              : '${NumberFormat.decimalPattern().format(count)} ${count == 1 ? 'person' : 'people'} joined with your code';

                          return IAMSettingMenu(
                            icon: Iconsax.profile_2user,
                            title: 'My Referrals',
                            subTitle: subTitle,
                            trailing: const Icon(
                              Iconsax.arrow_right_3,
                              size: 18,
                            ),
                            onTap: _openReferrals,
                          );
                        },
                      ),
                    ],
                    IAMSettingMenu(
                      icon: Iconsax.home,
                      title: 'My Addresses',
                      subTitle: 'Delivery Address',
                      onTap: () => Get.to(() => const UserAddressScreen()),
                    ),
                    IAMSettingMenu(
                      icon: Iconsax.shopping_cart,
                      title: 'My Cart',
                      subTitle: 'Items added to Cart',
                      onTap: () => Get.to(() => const CartScreen()),
                    ),
                    IAMSettingMenu(
                      icon: Iconsax.bag_tick,
                      title: 'My Orders',
                      subTitle: 'Track In-Progress and Completed Orders',
                      onTap: () => Get.to(() => const OrderScreen()),
                    ),
                    if (_canUseReferralFeatures)
                      IAMSettingMenu(
                        icon: Iconsax.receipt_text,
                        title: 'Referral Orders',
                        subTitle: 'Orders from buyers using your code',
                        onTap: () =>
                            Get.to(() => const ReferralOrdersScreen()),
                      ),

                    /*IAMSettingMenu(
                    icon: Iconsax.bank,
                    title: 'Bank Account',
                    subTitle: 'Manage Connected Banks',
                  ),*/

                    // IAMSettingMenu(
                    //   icon: Iconsax.discount_shape,
                    //   title: 'Vouchers',
                    //   subTitle: 'Manage Discount Coupons',
                    // ),

                    /*IAMSettingMenu(
                    icon: Iconsax.gift,
                    title: 'Invite Friends',
                    subTitle: 'Share Referral Code',
                  ),*/

                    //INVITE FRIENDS VIEWS USER ID WHRE USERS CAN COPY AND WILL THEN SEND A DOWNLOADABLE APP URL WITH THEIR REFERRAL CODE AUTOMATICALLY INSERTED
                    IAMSettingMenu(
                      icon: Iconsax.message_question,
                      title: 'Help Center',
                      subTitle: 'FAQs',
                      onTap: () => Get.to(() => const HelpCenterScreen()),
                    ),
                    // IAMSettingMenu(
                    //   icon: Iconsax.notification,
                    //   title: 'Notifications',
                    //   subTitle: 'Customize your Notifications',
                    // ),
                    // IAMSettingMenu(
                    //   icon: Iconsax.security_card,
                    //   title: 'Account Privacy',
                    //   subTitle: 'Manage security and privacy settings',
                    // ),

                    /// -- App Settings
                    SizedBox(height: IAMSizes.spaceBtwSections),
                    IAMSectionHeading(
                      title: 'App Settings',
                      showActionButton: false,
                    ),

                    SizedBox(height: IAMSizes.spaceBtwItems),
                    // IAMSettingMenu(
                    //   icon: Iconsax.document_upload,
                    //   title: 'Load Data',
                    //   subTitle: 'Upload Data to your Cloud Firebase',
                    // ),

                    /*IAMSettingMenu(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subTitle:
                        'Use your current location to show nearby results',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ), */

                    // IAMSettingMenu
                    // IAMSettingMenu(
                    //   icon: Iconsax.security_user,
                    //   title: 'Safe Mode',
                    //   subTitle: 'Search result is safe for all ages',
                    //   trailing: Switch(value: false, onChanged: (value) {}),
                    // ),
                    //
                    //                  // Dark / Light Mode
                    IAMSettingMenu(
                      icon: Iconsax.moon,
                      title: 'Dark Mode',
                      subTitle: 'Switch between light and dark theme',
                      trailing: Obx(() {
                        final controller = ThemeController.instance;
                        return Switch(
                          value: controller.isDarkMode,
                          onChanged: controller.toggleTheme,
                        );
                      }),
                    ),
                    //
                    //
                    //// IAMSettingMenu
                    /*IAMSettingMenu(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subTitle: 'Use high-quality images',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),*/

                    //Logout Button
                    const SizedBox(height: IAMSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => AuthController.instance.logout(),
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwSections * 2.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcomSalesSummaryView extends StatelessWidget {
  const _EcomSalesSummaryView({
    required this.ecomSalesFuture,
    required this.referralsFuture,
    required this.onReferralTap,
    required this.showReferralMetric,
  });

  final Future<ApiResponse<EcomSalesCommissionTotalData?>> ecomSalesFuture;
  final Future<ApiResponse<ReferralData?>> referralsFuture;
  final VoidCallback onReferralTap;
  final bool showReferralMetric;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<EcomSalesCommissionTotalData?>>(
      future: ecomSalesFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final success =
            snapshot.data?.success == true && snapshot.data?.data != null;
        final data = snapshot.data?.data;

        return _EcomSalesCardShell(
          child: Row(
            children: [
              Expanded(
                child: _AccountMetricCard(
                  label: 'Ecom Sales',
                  value: isLoading || !success
                      ? null
                      : data?.totalNetCommission,
                  suffix: '',
                  icon: Iconsax.wallet_money,
                  onTap: success && data != null
                      ? () => _showEcomSalesDetails(context, data)
                      : null,
                  valueFormatter: _formatEcomSalesCurrency,
                ),
              ),
              if (showReferralMetric) ...[
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: FutureBuilder<ApiResponse<ReferralData?>>(
                    future: referralsFuture,
                    builder: (context, referralSnapshot) {
                      final referralData = referralSnapshot.data?.data;
                      final referralCount = referralData?.totalReferrals;
                      final referralSuccess =
                          referralSnapshot.data?.success == true &&
                          referralData != null;
                      final referralLoading =
                          referralSnapshot.connectionState ==
                          ConnectionState.waiting;

                      return _AccountMetricCard(
                        label: 'Referrals',
                        value: referralLoading || !referralSuccess
                            ? null
                            : referralCount,
                        suffix: referralCount == 1 ? 'person' : 'people',
                        icon: Iconsax.profile_2user,
                        onTap: onReferralTap,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReferralIdSheet extends StatelessWidget {
  const _ReferralIdSheet({
    required this.referralId,
    required this.onCopy,
    required this.onShare,
  });

  final String referralId;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    final code = referralId.isEmpty ? 'N/A' : referralId;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          IAMSizes.md,
          0,
          IAMSizes.md,
          IAMSizes.md,
        ),
        padding: const EdgeInsets.all(IAMSizes.lg),
        decoration: BoxDecoration(
          color: darkMode ? IAMColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
          ),
          boxShadow: [
            BoxShadow(
              color: IAMColors.black.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF7D6),
                    Color(0xFFFFFFFF),
                    Color(0xFFE0B52D),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Iconsax.ticket_star,
                      color: IAMColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: IAMSizes.md),
                  Text(
                    'My Referral Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: IAMColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: IAMSizes.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: IAMSizes.md,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9D28A)),
                    ),
                    child: Text(
                      code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: IAMColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IAMSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Iconsax.copy, size: 18),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: darkMode
                            ? IAMColors.darkerGrey
                            : const Color(0xFFE3D6AD),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: IAMSizes.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Iconsax.share, size: 18),
                    label: const Text('Share Code'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: IAMColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EcomSalesCardShell extends StatelessWidget {
  const _EcomSalesCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: darkMode ? 0.10 : 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: child,
    );
  }
}

void _showEcomSalesDetails(
  BuildContext context,
  EcomSalesCommissionTotalData data,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final darkMode = IAMHelperFunctions.isDarkMode(context);

      return SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.86,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              IAMSizes.md,
              0,
              IAMSizes.md,
              IAMSizes.md,
            ),
            padding: const EdgeInsets.fromLTRB(
              IAMSizes.lg,
              IAMSizes.md,
              IAMSizes.lg,
              IAMSizes.lg,
            ),
            decoration: BoxDecoration(
              color: darkMode ? IAMColors.dark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: darkMode
                    ? IAMColors.darkerGrey
                    : const Color(0xFFF1E8D2),
              ),
              boxShadow: [
                BoxShadow(
                  color: IAMColors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: IAMColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Iconsax.wallet_money,
                        color: IAMColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: IAMSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ecom Sales Details',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: IAMSizes.xs),
                          Text(
                            'Account ${data.idno}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: darkMode
                                      ? Colors.white70
                                      : IAMColors.darkerGrey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.lg),
                _EcomSalesBreakdownRow(
                  label: 'Total Net Commission',
                  value: data.totalNetCommission,
                  icon: Iconsax.money_recive,
                  highlight: true,
                  valueFormatter: _formatEcomSalesCurrency,
                ),
                const SizedBox(height: IAMSizes.sm),
                _EcomSalesBreakdownRow(
                  label: 'Total Quantity',
                  value: data.totalQuantity,
                  icon: Iconsax.box,
                ),
                const SizedBox(height: IAMSizes.md),
                Expanded(
                  child: _EcomSalesDetailsList(
                    future: ApiMiddleware.commissions.getEcomSalesDetails(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _EcomSalesBreakdownRow extends StatelessWidget {
  const _EcomSalesBreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.valueFormatter,
  });

  final String label;
  final num value;
  final IconData icon;
  final bool highlight;
  final String Function(num value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);
    final formatted =
        valueFormatter?.call(value) ??
        NumberFormat.decimalPattern().format(value);

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: highlight
            ? IAMColors.primary.withValues(alpha: darkMode ? 0.20 : 0.12)
            : (darkMode ? IAMColors.black : const Color(0xFFFAF8F2)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? IAMColors.primary.withValues(alpha: 0.36)
              : (darkMode ? IAMColors.darkerGrey : const Color(0xFFF0E8D7)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IAMColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: IAMColors.primary, size: 20),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            formatted,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? IAMColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EcomSalesDetailsList extends StatelessWidget {
  const _EcomSalesDetailsList({required this.future});

  final Future<ApiResponse<List<EcomSalesCommissionDetailItem?>>> future;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return FutureBuilder<ApiResponse<List<EcomSalesCommissionDetailItem?>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data;
        final details =
            response?.data
                ?.whereType<EcomSalesCommissionDetailItem>()
                .toList() ??
            const <EcomSalesCommissionDetailItem>[];

        if (response?.success != true) {
          return _EcomSalesDetailsState(
            icon: Iconsax.info_circle,
            message: response?.message ?? 'Unable to load Ecom Sales details.',
          );
        }

        if (details.isEmpty) {
          return const _EcomSalesDetailsState(
            icon: Iconsax.receipt_search,
            message: 'No Ecom Sales details found for the last 30 days.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: details.length,
          separatorBuilder: (_, __) => const SizedBox(height: IAMSizes.sm),
          itemBuilder: (context, index) {
            final item = details[index];
            return _EcomSalesDetailTile(item: item, darkMode: darkMode);
          },
        );
      },
    );
  }
}

class _EcomSalesDetailTile extends StatelessWidget {
  const _EcomSalesDetailTile({
    required this.item,
    required this.darkMode,
  });

  final EcomSalesCommissionDetailItem item;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final refNo = item.refNo.isEmpty ? 'No reference' : item.refNo;
    final title = item.tranDesc.isEmpty ? item.itemCode : item.tranDesc;
    final date = _formatEcomSalesDate(item.tranDate);

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: darkMode ? IAMColors.black : const Color(0xFFFAF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF0E8D7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IAMColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.receipt_item,
              color: IAMColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: IAMSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  refNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  title.isEmpty ? 'Ecom Sales transaction' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: darkMode ? Colors.white70 : IAMColors.darkerGrey,
                  ),
                ),
                const SizedBox(height: IAMSizes.xs),
                Text(
                  '$date | Qty ${item.quantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: darkMode ? Colors.white60 : IAMColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: IAMSizes.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 118),
            child: Text(
              _formatEcomSalesCurrency(item.netCommission),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: IAMColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcomSalesDetailsState extends StatelessWidget {
  const _EcomSalesDetailsState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

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
                color: darkMode ? Colors.white70 : IAMColors.darkerGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatEcomSalesCurrency(num value) {
  return NumberFormat.currency(
    locale: 'en_PH',
    symbol: 'PHP ',
    decimalDigits: 2,
  ).format(value);
}

String _formatEcomSalesDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? 'No date' : value;
  return DateFormat('MMM d, yyyy').format(parsed);
}

class _AccountMetricCard extends StatelessWidget {
  const _AccountMetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    this.onTap,
    this.valueFormatter,
  });

  final String label;
  final num? value;
  final String suffix;
  final IconData icon;
  final VoidCallback? onTap;
  final String Function(num value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final metricValue = value;
    final formatted = metricValue == null
        ? '--'
        : valueFormatter?.call(metricValue) ??
              NumberFormat.decimalPattern().format(metricValue);
    final suffixText = suffix.isEmpty ? '' : ' $suffix';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.all(IAMSizes.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              _MetricIcon(icon: icon),
              const SizedBox(width: IAMSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.xs),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatted,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          TextSpan(
                            text: suffixText,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
