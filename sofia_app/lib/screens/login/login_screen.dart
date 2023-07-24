import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/auth_provider.dart';
import 'package:sofia_app/providers/login_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final AuthProvider authProvider;

  const LoginScreen({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>(
          create: (_) => LoginProvider(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login Screen'),
        ),
        body: Consumer2<LoginProvider, AuthProvider>(
          builder: (context, loginProvider, authProvider, _) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      loginProvider.setUsername(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: !loginProvider.isPasswordVisible,
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
                          loginProvider.isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          loginProvider.toggleVisiblePassword();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      loginProvider.setPassword(value);
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: loginProvider.rememberMe,
                        onChanged: (value) {
                          loginProvider.toggleRememberMe(value!);
                        },
                      ),
                      Text('Remember me'),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          loginProvider.forgotPassword(context);
                        },
                        child: Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await loginProvider.login(context);
                      if (authProvider.isLoggedIn) {
                        Navigator.pushNamed(context, '/home');
                      }
                    },
                    child: Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      loginProvider.registerUser(context);
                    },
                    child: Text('New User? Register Here'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
