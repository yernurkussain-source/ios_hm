import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'coin.dart';

Future<void> showCoinReward(
  BuildContext context, {
  required int amount,
  required String title,
  String? subtitle,
}) {
  HapticFeedback.heavyImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) =>
        _CoinRewardSheet(amount: amount, title: title, subtitle: subtitle),
  );
}

class _CoinRewardSheet extends StatefulWidget {
  final int amount;
  final String title;
  final String? subtitle;

  const _CoinRewardSheet({
    required this.amount,
    required this.title,
    this.subtitle,
  });

  @override
  State<_CoinRewardSheet> createState() => _CoinRewardSheetState();
}

class _CoinRewardSheetState extends State<_CoinRewardSheet>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 170,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final t = controller.value;
                  final pop = Curves.elasticOut.transform(
                    (t / 0.7).clamp(0, 1),
                  );
                  final burst = Curves.easeOutCubic.transform(t);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Particles flying out of the coin.
                      for (var i = 0; i < 14; i++)
                        Transform.translate(
                          offset: Offset.fromDirection(
                            i * 2 * pi / 14,
                            30 + 70 * burst * (i.isEven ? 1 : 0.75),
                          ),
                          child: Opacity(
                            opacity: (1 - burst).clamp(0, 1),
                            child: Container(
                              width: i.isEven ? 10 : 7,
                              height: i.isEven ? 10 : 7,
                              decoration: BoxDecoration(
                                color: i % 3 == 0 ? accent : coinGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      // Coin: pops in and spins once around its Y axis.
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..scaleByDouble(pop, pop, 1, 1)
                          ..rotateY(2 * pi * burst),
                        child: const CoinIcon(size: 96),
                      ),
                    ],
                  );
                },
              ),
            ),
            AnimatedCount(
              value: widget.amount,
              from: 0,
              prefix: '+',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                color: ink,
              ),
            ),
            const Text(
              'Mood Coins',
              style: TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }
}
