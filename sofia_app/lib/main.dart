import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/databases/app_database.dart';
import 'package:sofia_app/providers/auth_provider.dart';
import 'package:sofia_app/providers/ble_provider.dart';
import 'package:sofia_app/screens/login/login_screen.dart';
import 'package:sofia_app/screens/registration/registration_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final userDao = database.userDao;
    final authProvider = AuthProvider();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: database),
            Provider<UserDao>.value(value: userDao),
            ChangeNotifierProvider(create: (_) => authProvider),
          ],
          child: const SofiaApp(),
        ),
      );
    });
  } else {
    runApp(const SofiaApp());
  }
}

class SofiaApp extends StatefulWidget {
  const SofiaApp({Key? key}) : super(key: key);

  @override
  State<SofiaApp> createState() => _SofiaAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _SofiaAppState? state = context.findAncestorStateOfType<_SofiaAppState>();
    state?.setLocale(newLocale);
  }
}

class _SofiaAppState extends State<SofiaApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('it'), // Italian
        Locale('es'), // Spanish
      ],
      locale: _locale,
      routes: {
        '/login': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, _) =>
                  LoginScreen(authProvider: authProvider),
            ),
        '/register': (context) => Consumer<UserDao>(
              builder: (context, userDao, _) => RegistrationScreen(),
            ),
        '/': (context) => ChangeNotifierProvider(
              // '/home'
              create: (_) => BleProvider(),
              child: Consumer2<UserDao, AuthProvider>(
                builder: (context, userDao, authProvider, _) =>
                    HomeScreen(userDao: userDao, authProvider: authProvider),
              ),
            ),
      },
    );
  }
}
