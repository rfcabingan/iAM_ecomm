import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:share_plus/share_plus.dart';

// const String kProductShareBaseUrl = 'https://iam-ecomm-share.vercel.app';

class IAMRatingAndShare extends StatelessWidget {
  const IAMRatingAndShare({super.key, required this.productCode, required this.shareLink});

  final String productCode;
  final String shareLink;

  void _shareProduct(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFFDBA724)),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'Check out this product on IAM Worldwide! 🛍️\n\n$shareLink',
                  subject: 'IAM Worldwide Product',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFFDBA724)),
              title: const Text('Copy Link'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: shareLink));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiMiddleware.productReview.getReviews(productCode),
      builder: (context, snapshot) {
        double average = 0;
        int count = 0;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.success) {
          final reviews = snapshot.data!.data ?? [];
          final validReviews = reviews.where((r) => r != null).toList();

          count = validReviews.length;

          if (count > 0) {
            final total = validReviews.fold<int>(
              0,
              (sum, r) => sum + (r!.rating ?? 0),
            );
            average = total / count;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Iconsax.star5, color: Color(0xFFDBA724), size: 24),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: average.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(text: '($count)'),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => _shareProduct(context),
              icon: const Icon(Icons.share, size: IAMSizes.iconMd),
            ),
          ],
        );
      },
    );
  }
}
