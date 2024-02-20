import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/registration_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../configs/app_strings.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
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

    final _firstHalfAnimation =
        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.6,
          0.8,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    final _secondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.8,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _firstHalfAnimation,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _welcomeImageAnimation,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 450, maxHeight: 400),
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
                      "Powered by",
                      style: TextStyle(fontSize: 15.0, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SlideTransition(
                    position: _welcomeImageAnimation,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 450, maxHeight: 400),
                      child: Image.asset(
                        'assets/introduction_animation/Mcallinn_Logo_Full_Color_Small.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      //errorText: context.read<RegistrationProvider>().emailError,
                      hintText: AppLocalizations.of(context)!.email,
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<RegistrationProvider>().setEmail(value);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      // errorText: context.read<RegistrationProvider>().usernameError,
                      hintText: AppLocalizations.of(context)!.username,
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
                      context.read<RegistrationProvider>().setUsername(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: !context
                        .watch<RegistrationProvider>()
                        .isPasswordVisible,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.password,
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
                          context.read<RegistrationProvider>().isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context
                              .read<RegistrationProvider>()
                              .toggleVisiblePassword();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      context.read<RegistrationProvider>().setPassword(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity, // Make the button full width
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await context
                            .read<RegistrationProvider>()
                            .registerUser();
                        if (context.mounted && result) {
                          buildShowDialog(
                            context,
                            title: 'Registration Successful',
                            content: 'Your registration was successful.',
                            result: result,
                          );
                        } else {
                          buildShowDialog(
                            context,
                            title: 'Error Occurred!!',
                            content: 'Please try again',
                            result: result,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // This sets the background color
                        foregroundColor: Colors
                            .white, // This sets the color of the text and icon
                        padding: EdgeInsets.symmetric(
                            vertical:
                                12), // This sets the padding inside the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // This sets the shape and border radius of the button
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> buildShowDialog(
    BuildContext context, {
    required String title,
    required String content,
    required bool result,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (result) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
