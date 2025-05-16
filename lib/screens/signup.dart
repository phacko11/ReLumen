import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Khởi tạo Firestore instance

  bool _isLoading = false;

  Future<void> _signupUser() async {
    print('Đang thử đăng ký với Email: ${_emailController.text.trim()}');
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      if (mounted) _showErrorDialog("Please fill in all fields."); 
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) _showErrorDialog("Passwords do not match!");
      return;
    }


    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('Bắt đầu gọi createUserWithEmailAndPassword...');
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('createUserWithEmailAndPassword thành công!');

      User? firebaseUser = userCredential.user; 

      if (firebaseUser != null) {
        print('ĐĂNG KÝ AUTH THÀNH CÔNG. UID: ${firebaseUser.uid}');

        print('Đang tạo user profile trên Firestore cho UID: ${firebaseUser.uid}...');
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'displayName': '', 
          'role': 'user',    
          'createdAt': FieldValue.serverTimestamp(), 
          'photoURL': null, 
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) _showErrorDialog("User creation successful but failed to get user details."); 
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed."; // English
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      print('FirebaseAuthException during registration:');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      if (mounted) _showErrorDialog(errorMessage);

    } catch (e, s) {
      print('UNEXPECTED ERROR during registration:');
      print('Error: $e');
      print('StackTrace: $s');
      if (mounted) _showErrorDialog("An unexpected error occurred during registration. Please try again."); // English
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Finished _signupUser processing, _isLoading = false');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration Notice'), // English
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up to ReLumen'), // English
        centerTitle: true,
      ),
      body: Padding(
        // ... (Phần UI của build method giữ nguyên như trước, đảm bảo các text là tiếng Anh nếu cần)
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Create New Account', // English
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email', // English
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password (min. 6 characters)', // English
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password', // English
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signupUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Sign Up', style: TextStyle(fontSize: 18)), // English
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have an account?"), // English
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        if (Navigator.canPop(context)) {
                           Navigator.pop(context);
                        }
                      },
                      child: const Text('Login now'), // English
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}