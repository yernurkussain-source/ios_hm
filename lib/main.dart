import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/auth_cubit.dart';
import 'blocs/cart_bloc.dart';
import 'screens/login_screen.dart';
import 'services/user_repository.dart';
import 'state/cart_provider.dart';
import 'state/notes_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Needed before using plugins (SharedPreferences) ahead of runApp().
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved settings first, so the first frame is already dark if needed.
  final prefs = await SharedPreferences.getInstance();
  // sqflite runs on Android, iOS and macOS; elsewhere (web, Windows) only the
  // demo login works.
  const sqlitePlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };
  final hasSqlite = !kIsWeb && sqlitePlatforms.contains(defaultTargetPlatform);
  runApp(MoodCartApp(prefs: prefs, users: hasSqlite ? UserRepository() : null));
}

class MoodCartApp extends StatelessWidget {
  final SharedPreferences prefs;
  final UserRepository? users;

  const MoodCartApp({super.key, required this.prefs, this.users});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: prefs),
        ChangeNotifierProvider(create: (_) => CartProvider(prefs)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotesProvider(prefs)),
        BlocProvider(create: (_) => AuthCubit(users: users)),
        BlocProvider(
          create: (context) => CartBloc(context.read<CartProvider>()),
        ),
      ],
      child: Selector<SettingsProvider, bool>(
        selector: (_, settings) => settings.darkMode,
        builder: (_, darkMode, _) => MaterialApp(
          title: 'MoodCart',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildAppTheme(dark: true),
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
