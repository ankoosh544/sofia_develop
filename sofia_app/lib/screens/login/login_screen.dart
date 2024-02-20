import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/main.dart';

import 'package:sofia_app/providers/login_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../password/forgot_password_screen.dart';
import '../../configs/app_strings.dart';
import 'package:sofia_app/storage/local_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _welcomeFirstHalfAnimation =
        Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final _welcomeImageAnimation =
        Tween<Offset>(begin: Offset(4, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
        ),
        backgroundColor: Colors.teal,
        resizeToAvoidBottomInset: false,
        body: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _animationController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SlideTransition(
                              position: _welcomeImageAnimation,
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: 450, maxHeight: 400),
                                child: Image.asset(
                                  'assets/introduction_animation/app_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SlideTransition(
                              position: _welcomeFirstHalfAnimation,
                              child: Text(
                                AppLocalizations.of(context)!.powered_by,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SlideTransition(
                              position: _welcomeImageAnimation,
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: 450, maxHeight: 400),
                                child: Image.asset(
                                  'assets/introduction_animation/Mcallinn_Logo_Full_Color_Small.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.username,
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<LoginProvider>()
                                    .setUsername(value);
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              obscureText: !context
                                  .watch<LoginProvider>()
                                  .isPasswordVisible,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.password,
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    context
                                            .read<LoginProvider>()
                                            .isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<LoginProvider>()
                                        .toggleVisiblePassword();
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<LoginProvider>()
                                    .setPassword(value);
                              },
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value:
                                      context.read<LoginProvider>().rememberMe,
                                  onChanged: (value) {
                                    context
                                        .read<LoginProvider>()
                                        .toggleRememberMe(value!);
                                    if (value) {
                                      var username = context
                                          .read<LoginProvider>()
                                          .username;
                                      var password = context
                                          .read<LoginProvider>()
                                          .password;
                                      LocalStore.setValue(
                                          key: 'username', value: username);
                                      LocalStore.setValue(
                                          key: 'password', value: password);
                                    } else {
                                      LocalStore.delete(key: 'username');
                                      LocalStore.delete(key: 'password');
                                    }
                                  },
                                ),
                                Text(
                                  AppLocalizations.of(context)!.rememberMe,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    forgotPassword(context);
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await context
                                      .read<LoginProvider>()
                                      .login();
                                  if (context.mounted) {
                                    if (result) {
                                      await Navigator.pushReplacementNamed(
                                          context, '/home');
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Login Failed'),
                                          content: Text(
                                              'Invalid username or password.'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    Text(AppLocalizations.of(context)!.login),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          '${AppLocalizations.of(context)!.powered_by} McAllinn Italian SRL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void forgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void registerUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => launchRegistrationScreen(),
      ),
    );
  }
}
