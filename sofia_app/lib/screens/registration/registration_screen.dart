import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/registration_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                errorText: context.read<RegistrationProvider>().emailError,
                hintText: AppLocalizations.of(context)!.email,
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
              ),
              onChanged: (value) {
                context.read<RegistrationProvider>().setEmail(value);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                errorText: context.read<RegistrationProvider>().usernameError,
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
                context.read<RegistrationProvider>().setUsername(value);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              obscureText:
                  !context.read<RegistrationProvider>().isPasswordVisible,
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
                    context.read<RegistrationProvider>().isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue,
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
            ElevatedButton(
              onPressed: () async {
                final result =
                    await context.read<RegistrationProvider>().registerUser();
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
              child: Text('Register'),
            ),
          ],
        ),
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
