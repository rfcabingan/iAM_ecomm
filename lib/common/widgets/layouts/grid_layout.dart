import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMGridLayout extends StatelessWidget {
  const IAMGridLayout({
    super.key,
    required this.itemCount,
    this.mainAxisExtent = 288,
    this.crossAxisCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final double? mainAxisExtent;
  final int? crossAxisCount;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? IAMBreakpoints.productGridCount(context);

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: IAMSizes.gridViewSpacing,
        crossAxisSpacing: IAMSizes.gridViewSpacing,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
