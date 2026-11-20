import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.radius = 15,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: context.palette.neutralSoft,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 40, color: context.palette.muted),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: context.palette.surface,
        child: Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    placeholder,
                    const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
          errorBuilder: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}
