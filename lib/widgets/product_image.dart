import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;

  const ProductImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.radius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: neutralSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 40, color: muted),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
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
    );
  }
}
