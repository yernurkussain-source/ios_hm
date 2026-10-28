import 'package:flutter/material.dart';

import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin.dart';

class ProfileScreen extends StatelessWidget {
  final ShopState shop;
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenCoins;

  const ProfileScreen({
    super.key,
    required this.shop,
    required this.onOpenFavorites,
    required this.onOpenCart,
    required this.onOpenCoins,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: ink,
            child: Icon(Icons.person, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'MoodCart Shopper',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            'Your personalized shopping space',
            style: TextStyle(color: muted),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _StatTile(label: 'Favorites', value: '${shop.favorites.length}'),
            const SizedBox(width: 10),
            _StatTile(label: 'In cart', value: '${shop.cartQuantity}'),
            const SizedBox(width: 10),
            _StatTile(label: 'Coins', value: '${shop.coins}'),
          ],
        ),
        const SizedBox(height: 16),
        _LevelCard(shop: shop, onTap: onOpenCoins),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('My Favorites'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenFavorites,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.toll_outlined),
                title: const Text('Mood Coins wallet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenCoins,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('My Cart'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenCart,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                value: shop.notificationsOn,
                onChanged: shop.setNotifications,
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final ShopState shop;
  final VoidCallback onTap;

  const _LevelCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final level = shop.level;
    final next = level.next;
    return Material(
      color: ink,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CoinIcon(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${level.name} member',
                          style: TextStyle(
                            color: level.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedCount(
                          value: shop.coins,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: shop.levelProgress,
                  minHeight: 6,
                  color: next?.color ?? level.color,
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? 'Top level · ${level.bonus} cashback'
                    : '${next.minCoins - shop.lifetimeCoins} coins to ${next.name}'
                          ' · ${level.bonus} cashback now',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
