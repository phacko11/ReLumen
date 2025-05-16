import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; 
import 'ai_assistant.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}); 

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();

      final scaffoldMessenger = ScaffoldMessenger.of(context); 

  
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Logout successful!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green, 
        ),
      );

    } catch (e) {
      print("Logout error: $e");
      final scaffoldMessenger = ScaffoldMessenger.of(context); 
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to ReLumen!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (user != null)
              Text(
                'Email: ${user.email}',
                style: const TextStyle(fontSize: 16),
              ),
            ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
            );
          },
          child: const Text('Ask Luminas about culture!!'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}