import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';

class IAMProductPriceText extends StatelessWidget {
  const IAMProductPriceText({
    super.key,
    this.currencySign = '₱',
    required this.price,
    this.maxLines = 1,
    this.isLarge = false,
    this.lineThrough = false,
  });

  final String currencySign, price;
  final int maxLines;
  final bool isLarge;
  final bool lineThrough;

  String _formatPrice(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return cleaned;

    final withoutCurrency = cleaned
        .replaceAll(currencySign, '')
        .replaceAll(',', '')
        .trim();

    final amount = double.tryParse(withoutCurrency);
    if (amount == null) return cleaned;

    final formatted = IAMFormatter.formatCurrency(amount);
    return formatted.replaceFirst('₱', '');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      currencySign + _formatPrice(price),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: isLarge
          ? Theme.of(context).textTheme.headlineMedium!.apply(
              decoration: lineThrough ? TextDecoration.lineThrough : null,
            )
          : Theme.of(context).textTheme.titleLarge!.apply(
              decoration: lineThrough ? TextDecoration.lineThrough : null,
            ),
    );
  }
}
