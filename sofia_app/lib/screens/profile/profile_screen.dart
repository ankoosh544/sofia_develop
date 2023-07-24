import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/auth_provider.dart';
import 'package:sofia_app/providers/profile_provider.dart';

import '../../configs/index.dart';
import '../../widgets/index.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SofiaAppBar(
        title: tabProfile,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            // if (!profileProvider.isDataLoaded) {
            // User data is not loaded yet, show loading indicator
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 64.0,
                  backgroundImage: AssetImage('assets/profile_image.png'),
                ),
                SizedBox(height: 16.0),
                Text(
                  profileProvider.userName ?? 'Username',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                SizedBox(height: 16.0),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text(profileProvider.user?.email ?? 'Email'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Logout logic
                    context.read<AuthProvider>().logout();
                    // Navigate to the login screen
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => LoginScreen(
                    //             authProvider: authProvider,
                    //           )),
                    //   (route) => false,
                    // );
                  },
                  child: Text('Logout'),
                ),
              ],
            );

            // } else if (profileProvider.user == null) {
            //   // User data is loaded, but user is not found
            //   return Center(
            //     child: Text('User not found'),
            //   );
            //} else {
            // User data is loaded and available, display user details
            //  return Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }
          },
        ),
      ),
    );
  }
}
