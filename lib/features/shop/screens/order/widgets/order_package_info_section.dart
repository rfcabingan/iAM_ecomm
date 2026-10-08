import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_type.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_accent_theme.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OrderPackageInfoSection extends StatelessWidget {
  const OrderPackageInfoSection({
    super.key,
    required this.display,
    this.packageCode = '',
  });

  final OrderPackageDisplay display;
  final String packageCode;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final directImage = display.imageUrl.trim();

    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: dark ? IAMColors.dark : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: IAMSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              directImage.isNotEmpty
                  ? _PackageImage(imageUrl: directImage, dark: dark)
                  : _PackageImageLoader(packageCode: packageCode, dark: dark),
              const SizedBox(width: IAMSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display.packageName.isNotEmpty
                          ? display.packageName
                          : 'Package',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (display.optionName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        display.optionName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark
                              ? IAMColors.lightGrey
                              : IAMColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageImageLoader extends StatelessWidget {
  const _PackageImageLoader({
    required this.packageCode,
    required this.dark,
  });

  final String packageCode;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (packageCode.isEmpty) {
      return _PackageImage(imageUrl: '', dark: dark);
    }

    return FutureBuilder(
      future: ApiMiddleware.packages.getPackages(),
      builder: (context, snapshot) {
        var url = '';
        if (snapshot.hasData && snapshot.data!.success) {
          for (final pkg in snapshot.data!.data ?? []) {
            if (pkg != null && pkg.packageCode == packageCode) {
              url = pkg.imageUrl.trim();
              break;
            }
          }
        }
        return _PackageImage(imageUrl: url, dark: dark);
      },
    );
  }
}

class _PackageImage extends StatelessWidget {
  const _PackageImage({required this.imageUrl, required this.dark});

  final String imageUrl;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final accent = OrderAccentTheme.forKind(OrderKind.package).accentColor;
    final placeholder = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: dark ? IAMColors.darkerGrey : IAMColors.softGrey,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
      ),
      child: Icon(Iconsax.gift, color: accent, size: 32),
    );

    if (imageUrl.trim().isEmpty) return placeholder;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: dark ? IAMColors.darkerGrey : IAMColors.light,
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 72,
          height: 72,
          fit: BoxFit.contain,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}
