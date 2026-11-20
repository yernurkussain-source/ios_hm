import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/root_screen.dart';
import 'state/cart_provider.dart';
import 'state/notes_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Needed before using plugins (SharedPreferences) ahead of runApp().
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved settings first, so the first frame is already dark if needed.
  final prefs = await SharedPreferences.getInstance();
  runApp(MoodCartApp(prefs: prefs));
}

class MoodCartApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MoodCartApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotesProvider(prefs)),
      ],
      child: Selector<SettingsProvider, bool>(
        selector: (_, settings) => settings.darkMode,
        builder: (_, darkMode, _) => MaterialApp(
          title: 'MoodCart',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildAppTheme(dark: true),
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const RootScreen(),
        ),
      ),
    );
  }
}
