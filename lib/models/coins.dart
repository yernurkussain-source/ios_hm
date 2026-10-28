import 'package:flutter/material.dart';

class CoinLevel {
  final String name;
  final int minCoins;
  final double multiplier;
  final Color color;

  const CoinLevel(this.name, this.minCoins, this.multiplier, this.color);

  static const all = [
    CoinLevel('Bronze', 0, 1.0, Color(0xFFC77B48)),
    CoinLevel('Silver', 100, 1.25, Color(0xFF9EA3AE)),
    CoinLevel('Gold', 300, 1.5, Color(0xFFF2B01E)),
    CoinLevel('Platinum', 700, 2.0, Color(0xFF7FB9C9)),
  ];

  static CoinLevel forCoins(int lifetime) =>
      all.lastWhere((level) => lifetime >= level.minCoins);

  String get bonus {
    final m = multiplier;
    return '×${m == m.roundToDouble() ? m.toInt() : m}';
  }

  CoinLevel? get next {
    final i = all.indexOf(this);
    return i + 1 < all.length ? all[i + 1] : null;
  }
}

enum CoinSource { checkout, checkIn, mission, redeem }

class CoinEntry {
  final String title;
  final int amount;
  final CoinSource source;
  final DateTime date;

  const CoinEntry(this.title, this.amount, this.source, this.date);

  IconData get icon => switch (source) {
    CoinSource.checkout => Icons.shopping_bag_rounded,
    CoinSource.checkIn => Icons.calendar_today_rounded,
    CoinSource.mission => Icons.emoji_events_rounded,
    CoinSource.redeem => Icons.local_offer_rounded,
  };
}

enum MissionType { favorites, itemsAdded, orders, streak }

class Mission {
  final String id;
  final String title;
  final String subtitle;
  final int reward;
  final int target;
  final MissionType type;
  final IconData icon;

  const Mission({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.target,
    required this.type,
    required this.icon,
  });

  static const all = [
    Mission(
      id: 'first_fav',
      title: 'Heart-taker',
      subtitle: 'Save 2 products to favorites',
      reward: 10,
      target: 2,
      type: MissionType.favorites,
      icon: Icons.favorite_rounded,
    ),
    Mission(
      id: 'bag3',
      title: 'Fill the bag',
      subtitle: 'Add 3 items to your cart',
      reward: 15,
      target: 3,
      type: MissionType.itemsAdded,
      icon: Icons.shopping_bag_rounded,
    ),
    Mission(
      id: 'first_order',
      title: 'First order',
      subtitle: 'Complete a demo checkout',
      reward: 25,
      target: 1,
      type: MissionType.orders,
      icon: Icons.local_shipping_rounded,
    ),
    Mission(
      id: 'streak3',
      title: 'On a roll',
      subtitle: 'Check in 3 days in a row',
      reward: 30,
      target: 3,
      type: MissionType.streak,
      icon: Icons.local_fire_department_rounded,
    ),
  ];
}
