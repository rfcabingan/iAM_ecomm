import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

/// Centers page content on wide screens while keeping phone layouts unchanged.
class IAMWebConstrained extends StatelessWidget {
  const IAMWebConstrained({
    super.key,
    required this.child,
    this.maxWidth = IAMBreakpoints.contentMaxWidth,
    this.padding,
    this.align = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry align;

  @override
  Widget build(BuildContext context) {
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    // Phone / compact layouts stay full-bleed like the native apps.
    if (!IAMBreakpoints.isDesktop(context)) {
      return content;
    }

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}

/// Soft page canvas for web: subtle vertical wash so full-bleed phone UIs
/// still feel intentional when centered on a large monitor.
class IAMWebPageScaffold extends StatelessWidget {
  const IAMWebPageScaffold({
    super.key,
    required this.child,
    this.maxWidth = IAMBreakpoints.contentMaxWidth,
    this.background,
  });

  final Widget child;
  final double maxWidth;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final wide = IAMBreakpoints.isDesktop(context);

    if (!kIsWeb || !wide) {
      return child;
    }

    return ColoredBox(
      color: background ??
          (dark ? IAMColors.dark : const Color(0xFFF7F5F0)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? [
                    IAMColors.black,
                    IAMColors.dark,
                    IAMColors.black,
                  ]
                : [
                    const Color(0xFFFFFBF3),
                    const Color(0xFFF7F5F0),
                    const Color(0xFFF3F1EB),
                  ],
          ),
        ),
        child: IAMWebConstrained(maxWidth: maxWidth, child: child),
      ),
    );
  }
}
