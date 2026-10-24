import 'package:flutter/material.dart';

import 'screens/root_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MoodCartApp());

class MoodCartApp extends StatelessWidget {
  const MoodCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodCart',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootScreen(),
    );
  }
}
