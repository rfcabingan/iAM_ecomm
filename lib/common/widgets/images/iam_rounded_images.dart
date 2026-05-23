import 'package:cached_network_image/cached_network_image.dart'; // [IEC-121]
import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMRoundedImage extends StatelessWidget {
  const IAMRoundedImage({
    super.key,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.applyImageRadius = true,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.backgroundColor,
    this.isNetworkImage = false,
    this.borderRadius = IAMSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadius.circular(borderRadius)
              : BorderRadius.zero,
          child: isNetworkImage
              ? CachedNetworkImage( // [IEC-121]
                  imageUrl: imageUrl,
                  fit: fit,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(
                    color: backgroundColor ?? Colors.transparent,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                )
              : Image(
                  fit: fit,
                  image: AssetImage(imageUrl),
                ),
        ),
      ),
    );
  }
}
