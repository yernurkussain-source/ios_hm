import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin.dart';
import '../widgets/coin_reward_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  final ShopState shop;

  const CartScreen({super.key, required this.shop});

  void checkout(BuildContext context) {
    final bonus = shop.level.bonus;
    final result = shop.checkout();
    if (result.earned == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Demo checkout completed!')));
      return;
    }
    showCoinReward(
      context,
      amount: result.earned,
      title: result.leveledUp
          ? 'Level up! You are ${shop.level.name} now 🎉'
          : 'Order placed!',
      subtitle: result.spent > 0
          ? 'You saved ${money((result.spent * ShopState.coinValue).toDouble())} with coins'
          : 'Cashback $bonus for your ${shop.level.name} level',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final entries = shop.cart.entries.toList();
          if (entries.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Explore the Feed and add something you like.',
              actionLabel: 'Continue shopping',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final item in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartItem(
                    productId: item.key,
                    quantity: item.value,
                    onChange: (diff) => shop.changeQuantity(item.key, diff),
                  ),
                ),
              const SizedBox(height: 8),
              _CoinsSwitch(shop: shop),
              const SizedBox(height: 12),
              _Summary(shop: shop),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => checkout(context),
                child: Text('Pay ${money(shop.payable)} · demo'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo only: no payment is processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final int productId;
  final int quantity;
  final ValueChanged<int> onChange;

  const _CartItem({
    required this.productId,
    required this.quantity,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final p = productById(productId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ProductImage(url: p.image, width: 70, height: 70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(money(p.price), style: const TextStyle(color: muted)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onChange(-1),
              icon: Icon(
                quantity == 1
                    ? Icons.delete_outline
                    : Icons.remove_circle_outline,
              ),
            ),
            Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => onChange(1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinsSwitch extends StatelessWidget {
  final ShopState shop;

  const _CoinsSwitch({required this.shop});

  @override
  Widget build(BuildContext context) {
    final usable = shop.maxRedeemable;
    final value = money((usable * ShopState.coinValue).toDouble());
    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
        secondary: const CoinIcon(size: 36),
        title: Text(
          usable > 0 ? 'Use $usable coins' : 'Mood Coins',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          usable > 0
              ? 'Save $value · balance ${shop.coins}'
              : 'No coins yet — check in daily to earn',
        ),
        value: shop.useCoins && usable > 0,
        onChanged: usable > 0 ? shop.setUseCoins : null,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final ShopState shop;

  const _Summary({required this.shop});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: muted)),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(
              'Subtotal · ${shop.cartQuantity} '
              '${shop.cartQuantity == 1 ? 'item' : 'items'}',
              money(shop.cartTotal),
            ),
            if (shop.coinDiscount > 0)
              row(
                'Coins discount',
                '−${money(shop.coinDiscount)}',
                style: const TextStyle(
                  color: Color(0xFF1E9E5A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            const Divider(height: 20),
            row(
              'Total',
              money(shop.payable),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CoinIcon(size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will earn ${shop.earnFor(shop.payable)} coins '
                      '(${shop.level.name} ${shop.level.bonus})',
                      style: const TextStyle(
                        color: accentDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
