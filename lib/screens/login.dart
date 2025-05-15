import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'home.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // Hàm xử lý đăng nhập
  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập email và mật khẩu.");
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('Đang thử đăng nhập với Email: ${_emailController.text.trim()}');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('signInWithEmailAndPassword thành công!');

      if (userCredential.user != null) {
        print('ĐĂNG NHẬP THÀNH CÔNG trên Firebase. UID: ${userCredential.user?.uid}');
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print('UserCredential.user là null sau khi đăng nhập thành công?');
        if (mounted) _showErrorDialog("Đăng nhập thành công nhưng không lấy được thông tin người dùng.");
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đăng nhập thất bại. Vui lòng thử lại.";
      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy người dùng với email này.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Sai mật khẩu. Vui lòng thử lại.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Địa chỉ email không hợp lệ.';
      } else if (e.code == 'invalid-credential') {
         errorMessage = 'Thông tin đăng nhập không hợp lệ (email hoặc mật khẩu sai).';
      }
      // In ra chi tiết lỗi FirebaseAuthException
      print('FirebaseAuthException khi đăng nhập:');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('StackTrace: ${e.stackTrace}');
      if (mounted) _showErrorDialog(errorMessage);

    } catch (e, s) {
      print('Lỗi KHÔNG XÁC ĐỊNH khi đăng nhập:');
      print('Error: $e');
      print('StackTrace: $s');
      if (mounted) _showErrorDialog("Đã có lỗi không mong muốn xảy ra. Vui lòng thử lại.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Kết thúc xử lý _loginUser, _isLoading = false');
      }
    }
  }

  // Hàm hiển thị dialog thông báo lỗi 
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông báo'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email của bạn',
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
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu của bạn',
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
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Đăng nhập', style: TextStyle(fontSize: 18)),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text('Đăng ký ngay'),
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