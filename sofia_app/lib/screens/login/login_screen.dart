import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sofia_app/providers/login_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';
import '../password/forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png'),
            SizedBox(
              height: 40,
            ),
            TextFormField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.username,
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.blue,
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
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.blue,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    context.read<LoginProvider>().isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue,
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
                Text('Remember me'),
                Spacer(),
                TextButton(
                  onPressed: () {
                    forgotPassword(context);
                  },
                  child: Text('Forgot Password?'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
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
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                registerUser(context);
              },
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
