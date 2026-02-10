import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IAMCartCounterIcon extends StatelessWidget {
  const IAMCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            Iconsax.shopping_bag,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                '2',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize:
                      Theme.of(context).textTheme.labelLarge!.fontSize! * 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
