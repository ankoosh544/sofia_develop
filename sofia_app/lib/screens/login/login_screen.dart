import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sofia_app/providers/login_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../configs/app_strings.dart';
import '../../main.dart';
import '../password/forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: Text('Login Screen'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logo),
            SizedBox(
              height: 40,
            ),
            TextFormField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.username,
                hintStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
              onChanged: (value) {
                context.read<LoginProvider>().setUsername(value);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              // obscureText: !loginProvider.isPasswordVisible,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.password,
                hintStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    context.read<LoginProvider>().isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    context.read<LoginProvider>().toggleVisiblePassword();
                  },
                ),
              ),
              onChanged: (value) {
                context.read<LoginProvider>().setPassword(value);
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: context.read<LoginProvider>().rememberMe,
                  onChanged: (value) {
                    context.read<LoginProvider>().toggleRememberMe(value!);
                  },
                ),
                const Text(
                  'Remember Me',
                  style: TextStyle(color: Colors.black),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    forgotPassword(context);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity, // This makes the button full width
              child: ElevatedButton(
                onPressed: () async {
                  final result = await context.read<LoginProvider>().login();
                  if (context.mounted) {
                    if (result) {
                      await Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Login Failed'),
                          content: Text('Invalid username or password.'),
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
                  backgroundColor:
                      Colors.black, // This sets the background color
                  foregroundColor:
                      Colors.white, // This sets the color of the text and icon
                  padding: EdgeInsets.symmetric(
                      vertical: 12), // This sets the padding inside the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // This sets the shape and border radius of the button
                  ),
                ),
                child: Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () {
                registerUser(context);
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.black, // This sets the color of the text
                backgroundColor:
                    Colors.grey, // This sets the background color of the button
                padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12), // This sets the padding inside the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // This sets the shape and border radius of the button
                ),
              ),
              child: Text('New User? Register Here'),
            ),
          ],
        ),
      ),
    );
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
