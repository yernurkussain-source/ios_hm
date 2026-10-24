import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  final ShopState shop;
  final ValueChanged<Product> onOpenProduct;
  final VoidCallback onBrowse;

  const FavoritesScreen({
    super.key,
    required this.shop,
    required this.onOpenProduct,
    required this.onBrowse,
  });

  void remove(BuildContext context, Product product) {
    shop.toggleFavorite(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} removed from favorites'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => shop.toggleFavorite(product),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final saved = shop.favorites;
    if (saved.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        subtitle: 'Tap a heart on a product to save it here.',
        actionLabel: 'Browse products',
        onAction: onBrowse,
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Text(
          '${saved.length} saved for later · swipe to remove',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        for (final product in saved)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(product.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => remove(context, product),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              child: ProductCard(
                product: product,
                isFavorite: true,
                onTap: () => onOpenProduct(product),
                onToggleFavorite: () => remove(context, product),
              ),
            ),
          ),
      ],
    );
  }
}
