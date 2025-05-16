import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';   
import 'login.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key}); // Removed const

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthWrapper: User is logged in. UID: ${snapshot.data!.uid}');
          return const MainScreen();
        } else {
          print('AuthWrapper: User is not logged in.');
          return const LoginScreen();
        }
      },
    );
  }
}