import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';

enum SortOrder { popular, priceLow, priceHigh }

const _moodIcons = {
  'All': Icons.grid_view_rounded,
  'Study': Icons.menu_book_rounded,
  'Gym': Icons.fitness_center_rounded,
  'Travel': Icons.flight_takeoff_rounded,
  'Cozy': Icons.local_cafe_rounded,
};

class FeedScreen extends StatefulWidget {
  final ShopState shop;
  final ValueChanged<Product> onOpenProduct;

  const FeedScreen({
    super.key,
    required this.shop,
    required this.onOpenProduct,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedMood = 'All';
  String query = '';
  SortOrder sort = SortOrder.popular;

  List<Product> get shown {
    final q = query.toLowerCase();
    final list = catalog.where((p) {
      final moodOk = selectedMood == 'All' || p.mood == selectedMood;
      final queryOk =
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return moodOk && queryOk;
    }).toList();
    switch (sort) {
      case SortOrder.popular:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOrder.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOrder.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = shown;
    final featured = catalog.reduce((a, b) => a.rating >= b.rating ? a : b);

    return ListView(
      key: const PageStorageKey('feedScroll'),
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => query = value),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _SortButton(
              value: sort,
              onSelected: (value) => setState(() => sort = value),
            ),
          ],
        ),
        const SizedBox(height: 18),

        _FeaturedBanner(
          product: featured,
          onTap: () => widget.onOpenProduct(featured),
        ),
        const SizedBox(height: 26),
        // 3. Mood filter.
        const _SectionHeader(title: 'Shop by mood'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final mood in moods)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      _moodIcons[mood],
                      size: 18,
                      color: selectedMood == mood ? Colors.white : ink,
                    ),
                    label: Text(mood),
                    selected: selectedMood == mood,
                    onSelected: (_) => setState(() => selectedMood = mood),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        // 4. Products.
        _SectionHeader(
          title: 'Explore products',
          trailing: '${products.length} items',
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          const SizedBox(
            height: 260,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Nothing found',
              subtitle: 'Try another mood or search word.',
            ),
          ),
        for (final product in products)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(
              product: product,
              isFavorite: widget.shop.isFavorite(product),
              onTap: () => widget.onOpenProduct(product),
              onToggleFavorite: () => widget.shop.toggleFavorite(product),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: muted)),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortOrder value;
  final ValueChanged<SortOrder> onSelected;

  const _SortButton({required this.value, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      tooltip: 'Sort',
      initialValue: value,
      onSelected: onSelected,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: SortOrder.popular, child: Text('Most popular')),
        PopupMenuItem(
          value: SortOrder.priceLow,
          child: Text('Price: low to high'),
        ),
        PopupMenuItem(
          value: SortOrder.priceHigh,
          child: Text('Price: high to low'),
        ),
      ],
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(color: ink, shape: BoxShape.circle),
        child: const Icon(Icons.tune_rounded, color: Colors.white),
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _FeaturedBanner({required this.product, required this.onTap});

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ink,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              left: -70,
              bottom: -90,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.55),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'TOP PICK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$greeting.\nShop your mood.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${product.name} · ${money(product.price)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ProductImage(
                    url: product.image,
                    width: 104,
                    height: 124,
                    radius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
