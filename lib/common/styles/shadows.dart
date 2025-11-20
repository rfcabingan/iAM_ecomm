import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';

class IAMShadowStyle {
  static final verticalProductShadow = BoxShadow(
    color: IAMColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(3, 2),
  );

  static final horizontalProductShadow = BoxShadow(
    color: IAMColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );
}
