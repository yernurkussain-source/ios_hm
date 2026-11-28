import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/theme/app_theme.dart';
import 'package:final_project/widgets/coin_reward_sheet.dart';

void main() {
  // 360 x 640 dp: a small Android phone, where the sheet used to overflow.
  testWidgets('coin reward sheet fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCoinReward(
                context,
                amount: 24,
                title: 'Order placed!',
                subtitle: 'You saved 50 ₸ with coins',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Awesome!'), findsOneWidget);
    expect(tester.takeException(), isNull); // no RenderFlex overflow
  });
}
