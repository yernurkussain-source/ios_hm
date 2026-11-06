import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_image.dart';

const _categoryIcons = {
  'Electronics': Icons.headphones_rounded,
  'Gadgets': Icons.watch_rounded,
  'Fashion': Icons.checkroom_rounded,
  'Photography': Icons.photo_camera_rounded,
  'Home': Icons.lightbulb_rounded,
};

class CatalogScreen extends StatefulWidget {
  final bool grid;
  final ValueChanged<Product> onOpenProduct;

  const CatalogScreen({
    super.key,
    required this.grid,
    required this.onOpenProduct,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Product> items = List.of(catalog);
  int _nextId = 100;


  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final base = catalog[_nextId % catalog.length];
    final id = _nextId++;
    final product = Product(
      id: id,
      name: 'New drop #${id - 99} · ${base.name}',
      description: base.description,
      image: base.image,
      price: base.price,
      rating: base.rating,
      reviews: 0,
      category: base.category,
      mood: base.mood,
      tags: base.tags,
    );
    generatedProducts.add(product);
    setState(() => items.insert(0, product));
  }

  void remove(Product product) {
    final index = items.indexOf(product);
    setState(() => items.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          duration: const Duration(seconds: 4),

          persist: false,
          action: SnackBarAction(
            label: 'UNDO',

            onPressed: () => setState(() => items.insert(index, product)),
          ),
        ),
      );
  }

  void reset() => setState(
    () => items
      ..clear()
      ..addAll(catalog),
  );

  Widget swipeToDelete(Product product, Widget child) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => remove(product),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Catalog is Empty',
        subtitle: 'You swiped everything away.',
        actionLabel: 'Reset Catalog',
        onAction: reset,
      );
    }

    final padding = EdgeInsets.fromLTRB(
      16,
      4,
      16,
      MediaQuery.paddingOf(context).bottom + 24,
    );

    const physics = AlwaysScrollableScrollPhysics();

    return RefreshIndicator(
      onRefresh: refresh,
      color: ink,
      child: widget.grid
          ? GridView.builder(
              key: const PageStorageKey('catalogGrid'),
              physics: physics,
              padding: padding,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => swipeToDelete(
                items[i],
                _GridCard(
                  product: items[i],
                  onTap: () => widget.onOpenProduct(items[i]),
                ),
              ),
            )
          : Card(
              margin: padding,
              child: ListView.separated(
                key: const PageStorageKey('catalogList'),
                physics: physics,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) => swipeToDelete(
                  items[i],
                  _ListRow(
                    product: items[i],
                    onTap: () => widget.onOpenProduct(items[i]),
                  ),
                ),
              ),
            ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ListRow({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: neutralSoft,
        child: Icon(
          _categoryIcons[product.category] ?? Icons.shopping_bag_rounded,
          color: ink,
        ),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Row(
        children: [
          _Tag(product.category),
          const SizedBox(width: 8),
          const Icon(Icons.star_rounded, size: 16, color: ink),
          Text(' ${product.rating}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            money(product.price),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          _CartToggle(product),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _GridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProductImage(
                url: product.image,
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _Tag(product.category)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: ink),
                          Text(
                            ' ${product.rating}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          money(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _CartToggle(product),
                    ],
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

class _CartToggle extends StatelessWidget {
  final Product product;

  const _CartToggle(this.product);

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<CartProvider, bool>(
      (cart) => cart.contains(product),
    );
    return IconButton(
      tooltip: inCart ? 'Remove from Cart' : 'Add to Cart',
      visualDensity: VisualDensity.compact,
      color: inCart ? accent : ink,
      onPressed: () => context.read<CartProvider>().toggle(product),
      icon: Icon(
        inCart ? Icons.shopping_cart : Icons.add_shopping_cart_rounded,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          color: accentDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
