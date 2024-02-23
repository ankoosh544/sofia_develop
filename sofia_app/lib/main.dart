import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/ble_provider.dart';
import 'package:sofia_app/providers/forgot_password_provider.dart';
import 'package:sofia_app/providers/ble_provider.dart';
import 'package:sofia_app/providers/registration_provider.dart';
import 'package:sofia_app/screens/car_status/car_status_screen.dart';
import 'package:sofia_app/screens/login/login_screen.dart';
import 'package:sofia_app/screens/registration/registration_screen.dart';
import 'package:sofia_app/services/ble_helper.dart';
import 'database/app_database.dart';
import 'providers/login_provider.dart';
import 'screens/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sofia_app/introduction_animation/introduction_animation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SofiaDatabase.initDatabase();
  if (Platform.isAndroid) {
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request().then((status) {
      _launchApp();
    });
  } else {
    _launchApp();
  }
}

void _launchApp() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleProvider(BLEHelper())),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
      ],
      child: const SofiaApp(),
    ),
  );
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

class _SofiaAppState extends State<SofiaApp> with TickerProviderStateMixin {
  Locale? _locale;
  AnimationController? _animationController;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    context.read<BleProvider>().connectToNearestDevice();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 8));
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
        '/home': (context) => IntroductionAnimationScreen(),
        '/login': (context) => launchLoginScreen(),
        '/register': (context) => launchRegistrationScreen(),
        '/': (context) => _launchHomeScreen(),
        '/car': (context) => _launchCarStatusScreen(),
      },
    );
  }
}

ChangeNotifierProvider<LoginProvider> launchLoginScreen() =>
    ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: const LoginScreen(),
    );

ChangeNotifierProvider<RegistrationProvider> launchRegistrationScreen() =>
    ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: const RegistrationScreen(),
    );

HomeScreen _launchHomeScreen() => const HomeScreen();

CarStatusScreen _launchCarStatusScreen() => const CarStatusScreen();
