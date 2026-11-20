import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/product.dart';
import '../services/product_api.dart';
import '../theme/app_theme.dart';
import '../widgets/product_image.dart';

class CloudScreen extends StatefulWidget {
  final ValueChanged<Product> onOpenProduct;
  final ProductApi? api;

  const CloudScreen({super.key, required this.onOpenProduct, this.api});

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  late final api = widget.api ?? ProductApi();
  List<Product>? products;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await api.fetchProducts();
      for (final p in result) {
        if (!allProducts.any((e) => e.id == p.id)) generatedProducts.add(p);
      }
      if (!mounted) return;
      setState(() => products = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
      if (products != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = products;
    if (items == null && loading) {
      return Center(
        child: CircularProgressIndicator(color: context.palette.ink),
      );
    }

    if (items == null) {
      return _ErrorView(
        message: error ?? 'Something went wrong.',
        onRetry: load,
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      color: context.palette.ink,
      child: ListView.separated(
        key: const PageStorageKey('cloudList'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ProductRow(
          product: items[i],
          onTap: () => widget.onOpenProduct(items[i]),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductRow({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: product.heroTag,
                child: ProductImage(
                  url: product.imageUrl,
                  width: 76,
                  height: 76,
                  radius: 14,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: context.palette.ink,
                        ),
                        Text(
                          ' ${product.rating} (${product.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.muted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          money(product.price),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: context.palette.muted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.palette.muted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
