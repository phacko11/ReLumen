// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Để điều hướng về sau khi đăng xuất

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Lấy instance của FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      // Điều hướng về LoginScreen và xóa tất cả các route trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Lỗi đăng xuất: $e");
      // Có thể hiển thị thông báo lỗi nếu cần
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại (nếu cần)
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
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
            Text(
              'Chào mừng đến với ứng dụng!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (user != null)
              Text(
                'Email của bạn: ${user.email}',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}