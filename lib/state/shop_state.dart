import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../models/coins.dart';
import '../models/product.dart';
import 'cart_provider.dart';

typedef CheckoutResult = ({int earned, int spent, bool leveledUp});

class ShopState extends ChangeNotifier {
  ShopState({DateTime Function()? clock, CartProvider? cart})
    : _now = clock ?? DateTime.now,
      cartProvider = cart ?? CartProvider() {
    cartProvider.addListener(notifyListeners);
  }

  final DateTime Function() _now;
  final CartProvider cartProvider;
  final Set<int> _favorites = {};
  bool notificationsOn = true;
  static const coinValue = 10;
  static const maxCoinShare = 0.3;

  int coins = 0;
  int lifetimeCoins = 0;
  int streak = 0;
  DateTime? _lastCheckIn;
  bool useCoins = false;
  int _orders = 0;
  final Set<String> _claimedMissions = {};
  final List<CoinEntry> history = [];

  CoinLevel get level => CoinLevel.forCoins(lifetimeCoins);
  double get levelProgress {
    final next = level.next;
    if (next == null) return 1;
    return (lifetimeCoins - level.minCoins) / (next.minCoins - level.minCoins);
  }

  int earnFor(double amount) => (amount / 1000 * level.multiplier).floor();
  bool isFavorite(Product product) => _favorites.contains(product.id);

  List<Product> get favorites =>
      allProducts.where((p) => _favorites.contains(p.id)).toList();

  Map<int, int> get cart => cartProvider.items;

  int get cartQuantity => cartProvider.quantity;

  double get cartTotal => cartProvider.total;

  int get maxRedeemable =>
      min(coins, (cartTotal * maxCoinShare / coinValue).floor());
  int get coinsToRedeem => useCoins ? maxRedeemable : 0;
  double get coinDiscount => (coinsToRedeem * coinValue).toDouble();
  double get payable => cartTotal - coinDiscount;

  void toggleFavorite(Product product) {
    if (!_favorites.add(product.id)) _favorites.remove(product.id);
    notifyListeners();
  }

  void addToCart(Product product, {int quantity = 1}) =>
      cartProvider.add(product, quantity: quantity);

  void changeQuantity(int productId, int difference) =>
      cartProvider.changeQuantity(productId, difference);

  void setUseCoins(bool value) {
    useCoins = value;
    notifyListeners();
  }

  CheckoutResult checkout() {
    if (cart.isEmpty) return (earned: 0, spent: 0, leveledUp: false);
    final before = level;
    final spent = coinsToRedeem;
    final earned = earnFor(payable);
    if (spent > 0) {
      coins -= spent;
      history.insert(
        0,
        CoinEntry('Used on order', -spent, CoinSource.redeem, _now()),
      );
    }
    _earn(earned, 'Order cashback', CoinSource.checkout);
    _orders++;
    useCoins = false;
    cartProvider.clear();
    return (earned: earned, spent: spent, leveledUp: level != before);
  }

  static int checkInReward(int day) => day == 7 ? 50 : day * 5;

  bool get checkedInToday =>
      _lastCheckIn != null && _sameDay(_lastCheckIn!, _now());

  bool get _streakAlive {
    final last = _lastCheckIn;
    if (last == null) return false;
    return _sameDay(last, _now().subtract(const Duration(days: 1)));
  }

  int get activeStreak => checkedInToday || _streakAlive ? streak : 0;
  int get daysInCycle {
    if (checkedInToday) return (streak - 1) % 7 + 1;
    return _streakAlive ? streak % 7 : 0;
  }

  int get nextCheckInDay => daysInCycle % 7 + 1;

  int checkIn() {
    if (checkedInToday) return 0;
    streak = _streakAlive ? streak + 1 : 1;
    _lastCheckIn = _now();
    final day = (streak - 1) % 7 + 1;
    final reward = checkInReward(day);
    _earn(reward, 'Daily check-in · day $day', CoinSource.checkIn);
    notifyListeners();
    return reward;
  }

  int missionProgress(Mission m) {
    final value = switch (m.type) {
      MissionType.favorites => _favorites.length,
      MissionType.itemsAdded => cartProvider.itemsAdded,
      MissionType.orders => _orders,
      MissionType.streak => streak,
    };
    return min(value, m.target);
  }

  bool isClaimed(Mission m) => _claimedMissions.contains(m.id);

  bool canClaim(Mission m) => !isClaimed(m) && missionProgress(m) >= m.target;

  int get claimableMissions => Mission.all.where(canClaim).length;

  int claimMission(Mission m) {
    if (!canClaim(m)) return 0;
    _claimedMissions.add(m.id);
    _earn(m.reward, 'Mission · ${m.title}', CoinSource.mission);
    notifyListeners();
    return m.reward;
  }

  void _earn(int amount, String title, CoinSource source) {
    if (amount <= 0) return;
    coins += amount;
    lifetimeCoins += amount;
    history.insert(0, CoinEntry(title, amount, source, _now()));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    cartProvider.removeListener(notifyListeners);
    super.dispose();
  }

  void setNotifications(bool value) {
    notificationsOn = value;
    notifyListeners();
  }
}
