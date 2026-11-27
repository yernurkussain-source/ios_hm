import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/coins.dart';
import '../models/product.dart';
import 'cart_provider.dart';

typedef CheckoutResult = ({int earned, int spent, bool leveledUp});

class ShopState extends ChangeNotifier {
  ShopState({DateTime Function()? clock, CartProvider? cart, this._prefs})
    : _now = clock ?? DateTime.now,
      cartProvider = cart ?? CartProvider() {
    _load();
    cartProvider.addListener(notifyListeners);
  }

  static const stateKey = 'shop_state';

  final DateTime Function() _now;
  final SharedPreferences? _prefs;
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

  @override
  void notifyListeners() {
    super.notifyListeners();
    _prefs?.setString(stateKey, jsonEncode(_toJson()));
  }

  Map<String, dynamic> _toJson() => {
    'coins': coins,
    'lifetimeCoins': lifetimeCoins,
    'streak': streak,
    'lastCheckIn': _lastCheckIn?.toIso8601String(),
    'orders': _orders,
    'itemsAdded': cartProvider.itemsAdded,
    'notificationsOn': notificationsOn,
    'claimedMissions': _claimedMissions.toList(),
    'favorites': _favorites.toList(),
    'favoriteProducts': extraProductsJson(_favorites),
    'history': history.map((e) => e.toJson()).toList(),
  };

  void _load() {
    final raw = _prefs?.getString(stateKey);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      registerProducts(
        (j['favoriteProducts'] as List<dynamic>? ?? []).map(
          (e) => Product.fromJson(e as Map<String, dynamic>),
        ),
      );
      coins = (j['coins'] as num?)?.toInt() ?? 0;
      lifetimeCoins = (j['lifetimeCoins'] as num?)?.toInt() ?? 0;
      streak = (j['streak'] as num?)?.toInt() ?? 0;
      _lastCheckIn = DateTime.tryParse(j['lastCheckIn'] as String? ?? '');
      _orders = (j['orders'] as num?)?.toInt() ?? 0;
      cartProvider.itemsAdded = (j['itemsAdded'] as num?)?.toInt() ?? 0;
      notificationsOn = j['notificationsOn'] as bool? ?? true;
      _claimedMissions.addAll(
        (j['claimedMissions'] as List<dynamic>? ?? []).cast<String>(),
      );
      final known = allProducts.map((p) => p.id).toSet();
      _favorites.addAll(
        (j['favorites'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toInt())
            .where(known.contains),
      );
      history.addAll(
        (j['history'] as List<dynamic>? ?? []).map(
          (e) => CoinEntry.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on FormatException {
      return;
    } on TypeError {
      return;
    }
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
