import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog.dart';
import '../models/coins.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin.dart';
import '../widgets/coin_reward_sheet.dart';


class CoinsScreen extends StatelessWidget {
  final ShopState shop;

  const CoinsScreen({super.key, required this.shop});

  void checkIn(BuildContext context) {
    final day = shop.nextCheckInDay;
    final reward = shop.checkIn();
    if (reward == 0) return;
    showCoinReward(
      context,
      amount: reward,
      title: day == 7 ? 'Jackpot! Day 7 bonus' : 'Day $day check-in',
      subtitle: '${shop.activeStreak}-day streak 🔥 Come back tomorrow.',
    );
  }

  void claim(BuildContext context, Mission mission) {
    final reward = shop.claimMission(mission);
    if (reward == 0) return;
    showCoinReward(
      context,
      amount: reward,
      title: 'Mission complete!',
      subtitle: mission.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Coins')),
      body: ListenableBuilder(
        listenable: shop,
        builder: (context, _) => ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            _BalanceCard(shop: shop),
            const SizedBox(height: 16),
            _CheckInCard(shop: shop, onCheckIn: () => checkIn(context)),
            const SizedBox(height: 26),
            _Header(
              'Missions',
              trailing: shop.claimableMissions > 0
                  ? '${shop.claimableMissions} ready'
                  : null,
            ),
            const SizedBox(height: 12),
            for (final m in Mission.all)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MissionTile(
                  mission: m,
                  progress: shop.missionProgress(m),
                  claimed: shop.isClaimed(m),
                  onClaim: () => claim(context, m),
                ),
              ),
            const SizedBox(height: 16),
            const _Header('How it works'),
            const SizedBox(height: 12),
            _HowItWorks(level: shop.level),
            const SizedBox(height: 26),
            const _Header('History'),
            const SizedBox(height: 12),
            if (shop.history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No coins yet — start with today\'s check-in!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final (i, e) in shop.history.indexed) ...[
                      if (i > 0) const Divider(height: 1, indent: 64),
                      _HistoryTile(entry: e),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? trailing;

  const _Header(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final ShopState shop;

  const _BalanceCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final level = shop.level;
    final next = level.next;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(28),
        gradient: RadialGradient(
          center: const Alignment(1.1, -1.1),
          radius: 1.2,
          colors: [level.color.withValues(alpha: 0.45), ink],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Balance', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: level.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: ink,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level.name.toUpperCase(),
                      style: const TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const CoinIcon(size: 44),
              const SizedBox(width: 12),
              AnimatedCount(
                value: shop.coins,
                from: 0,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '≈ ${money((shop.coins * ShopState.coinValue).toDouble())} to spend'
            '  ·  ${level.bonus} cashback',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: shop.levelProgress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: next?.color ?? level.color,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? 'Top level reached — enjoy ${level.bonus} cashback!'
                : '${next.minCoins - shop.lifetimeCoins} more coins to '
                      '${next.name} (${next.bonus} cashback)',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final ShopState shop;
  final VoidCallback onCheckIn;

  const _CheckInCard({required this.shop, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final collected = shop.daysInCycle;
    final done = shop.checkedInToday;
    final next = shop.nextCheckInDay;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Daily check-in',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: accent,
                  size: 20,
                ),
                Text(
                  ' ${shop.activeStreak}-day streak',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var day = 1; day <= 7; day++)
                  _DayDot(
                    day: day,
                    reward: ShopState.checkInReward(day),
                    collected: day <= collected,
                    isNext: !done && day == next,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: done
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      onCheckIn();
                    },
              icon: Icon(
                done ? Icons.check_circle_rounded : Icons.touch_app_rounded,
              ),
              label: Text(
                done
                    ? 'Checked in · come back tomorrow'
                    : 'Check in · +${ShopState.checkInReward(next)} coins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final int day;
  final int reward;
  final bool collected;
  final bool isNext;

  const _DayDot({
    required this.day,
    required this.reward,
    required this.collected,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final isJackpot = day == 7;
    final size = isJackpot ? 40.0 : 34.0;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: collected ? ink : (isNext ? accentSoft : neutralSoft),
            border: isNext ? Border.all(color: accent, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: collected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : isJackpot
              ? const CoinIcon(size: 26)
              : Text(
                  '+$reward',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isNext ? accentDeep : muted,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          isJackpot ? '+$reward' : 'Day $day',
          style: TextStyle(
            fontSize: 11,
            color: isJackpot ? accentDeep : muted,
            fontWeight: isJackpot ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MissionTile extends StatelessWidget {
  final Mission mission;
  final int progress;
  final bool claimed;
  final VoidCallback onClaim;

  const _MissionTile({
    required this.mission,
    required this.progress,
    required this.claimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final ready = !claimed && progress >= mission.target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: claimed ? neutralSoft : accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(mission.icon, color: claimed ? muted : accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mission.subtitle,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress / mission.target,
                            minHeight: 6,
                            color: claimed ? muted : ink,
                            backgroundColor: neutralSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progress/${mission.target}',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (claimed)
              const Icon(Icons.verified_rounded, color: muted)
            else if (ready)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: onClaim,
                child: Text('Claim +${mission.reward}'),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 18),
                  Text(
                    ' ${mission.reward}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  final CoinLevel level;

  const _HowItWorks({required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.shopping_bag_outlined),
              title: Text('Earn on every order'),
              subtitle: Text('1 coin per 1 000 ₸ × your level bonus'),
            ),
            const ListTile(
              leading: Icon(Icons.local_offer_outlined),
              title: Text('Spend in the cart'),
              subtitle: Text('1 coin = 10 ₸, up to 30% of the order'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  for (final l in CoinLevel.all)
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: l.color,
                            size: l == level ? 30 : 24,
                          ),
                          Text(
                            l.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: l == level
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          Text(
                            l.bonus,
                            style: const TextStyle(fontSize: 11, color: muted),
                          ),
                        ],
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

class _HistoryTile extends StatelessWidget {
  final CoinEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final positive = entry.amount > 0;
    final d = entry.date;
    final time =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}'
        ' · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: positive ? accentSoft : neutralSoft,
        child: Icon(entry.icon, size: 20, color: positive ? accent : ink),
      ),
      title: Text(entry.title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        '${positive ? '+' : ''}${entry.amount}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: positive ? const Color(0xFF1E9E5A) : ink,
        ),
      ),
    );
  }
}
