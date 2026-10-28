import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const coinGold = Color(0xFFF5B82E);
const coinGoldDeep = Color(0xFFD98E04);
const coinGoldLight = Color(0xFFFFE08A);

class CoinIcon extends StatelessWidget {
  final double size;

  const CoinIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.09),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [coinGoldLight, coinGold, coinGoldDeep],
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: size * 0.05,
          ),
        ),
        child: Text(
          'M',
          style: TextStyle(
            color: const Color(0xFF8A5600),
            fontSize: size * 0.48,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String prefix;
  final int? from;

  const AnimatedCount({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.from,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from?.toDouble(), end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('$prefix${v.round()}', style: style),
    );
  }
}

class CoinPill extends StatelessWidget {
  final int coins;
  final bool hasNews;
  final VoidCallback onTap;

  const CoinPill({
    super.key,
    required this.coins,
    required this.onTap,
    this.hasNews = false,
  });

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: hasNews,
      smallSize: 10,
      child: Material(
        color: surface,
        shape: const StadiumBorder(side: BorderSide(color: line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 24),
                const SizedBox(width: 6),
                AnimatedCount(
                  value: coins,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
