import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/data/catalog.dart';
import 'package:final_project/models/coins.dart';
import 'package:final_project/state/shop_state.dart';

void main() {
  late DateTime now;
  late ShopState shop;

  setUp(() {
    now = DateTime(2026, 10, 20, 10);
    shop = ShopState(clock: () => now);
  });

  test('daily check-in builds a streak and resets after a missed day', () {
    expect(shop.checkIn(), 5); // day 1
    expect(shop.checkIn(), 0); // only once per day

    now = now.add(const Duration(days: 1));
    expect(shop.checkIn(), 10); // day 2
    expect(shop.activeStreak, 2);

    now = now.add(const Duration(days: 2)); // missed a day
    expect(shop.activeStreak, 0);
    expect(shop.checkIn(), 5); // back to day 1
    expect(shop.coins, 20);
  });

  test('day 7 gives the jackpot', () {
    var total = 0;
    for (var i = 0; i < 7; i++) {
      total += shop.checkIn();
      now = now.add(const Duration(days: 1));
    }
    expect(total, 5 + 10 + 15 + 20 + 25 + 30 + 50);
    expect(shop.daysInCycle, 0); // new cycle starts
  });

  test('checkout earns cashback and redeems coins up to 30%', () {
    shop.coins = 500;
    shop.addToCart(catalog.first); // 24 990 ₸
    shop.setUseCoins(true);

    expect(shop.maxRedeemable, 500); // 30% cap would allow 749
    expect(shop.coinDiscount, 5000);

    final result = shop.checkout();
    expect(result.spent, 500);
    expect(result.earned, 19); // floor(19 990 / 1000)
    expect(shop.coins, 19);
    expect(shop.cart, isEmpty);
  });

  test('missions become claimable and pay once', () {
    final bag = Mission.all.firstWhere((m) => m.id == 'bag3');
    expect(shop.canClaim(bag), isFalse);

    shop.addToCart(catalog.first, quantity: 3);
    expect(shop.canClaim(bag), isTrue);
    expect(shop.claimMission(bag), 15);
    expect(shop.claimMission(bag), 0);
  });

  test('level grows with lifetime coins', () {
    expect(shop.level.name, 'Bronze');
    final bag = Mission.all.firstWhere((m) => m.id == 'bag3');
    shop.addToCart(catalog[3], quantity: 2); // 139 980 ₸ → 139 coins
    shop.checkout();
    shop.claimMission(bag);
    expect(shop.lifetimeCoins, greaterThanOrEqualTo(100));
    expect(shop.level.name, 'Silver');
  });
}
