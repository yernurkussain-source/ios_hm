import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin.dart';
import '../widgets/glass.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ShopState shop;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.shop,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void addToCart() {
    HapticFeedback.mediumImpact();
    final p = widget.product;
    widget.shop.addToCart(p, quantity: quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$quantity × ${p.name} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final extraTags = p.tags.where((t) => t != p.mood);
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GlassIconButton(
              tooltip: 'Back',
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 64,
        actions: [
          ListenableBuilder(
            listenable: widget.shop,
            builder: (context, _) {
              final saved = widget.shop.isFavorite(p);
              return GlassIconButton(
                tooltip: saved ? 'Remove from favorites' : 'Add to favorites',
                icon: saved ? Icons.favorite : Icons.favorite_border,
                color: saved ? accent : null,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.shop.toggleFavorite(p);
                },
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            Hero(
              tag: p.heroTag,
              child: ProductImage(
                url: p.image,
                width: double.infinity,
                height: 420,
                radius: 0,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                decoration: const BoxDecoration(
                  color: canvas,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.category.toUpperCase(),
                      style: const TextStyle(
                        color: accent,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: ink),
                        Text(
                          ' ${p.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${p.reviews} reviews)',
                          style: const TextStyle(color: muted),
                        ),
                        const Spacer(),
                        Text(
                          money(p.price),
                          style: const TextStyle(
                            color: ink,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CoinIcon(size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Earn ${widget.shop.earnFor(p.price * quantity)} '
                              'Mood Coins with this purchase',
                              style: const TextStyle(
                                color: accentDeep,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${widget.shop.level.name} '
                            '${widget.shop.level.bonus}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.mood, size: 18, color: ink),
                          label: Text(p.mood),
                        ),
                        for (final tag in extraTags) Chip(label: Text(tag)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton.filledTonal(
                              tooltip: 'Decrease',
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Increase',
                              onPressed: () => setState(() => quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // LAB 7: in-body back button → Navigator.pop.
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Products'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Glass(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    Text(
                      money(p.price * quantity),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: addToCart,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
