import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'home.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Tạo các controller để lấy giá trị từ TextField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Khởi tạo Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Để hiển thị trạng thái loading

  // Hàm xử lý đăng ký
  Future<void> _signupUser() async {
    // In ra email và mật khẩu người dùng nhập vào TRƯỚC KHI gọi Firebase
    print('Đang thử đăng ký với Email: ${_emailController.text.trim()}');
    print('Mật khẩu nhập vào: ${_passwordController.text}'); // Lưu ý: Không nên in mật khẩu trong ứng dụng thực tế

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      if (mounted) _showErrorDialog("Vui lòng điền đầy đủ thông tin.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) _showErrorDialog("Mật khẩu xác nhận không khớp!");
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

      if (userCredential.user != null) {
        print('ĐĂNG KÝ THÀNH CÔNG trên Firebase. UID: ${userCredential.user?.uid}');

        if (mounted) {
          print('Chuẩn bị điều hướng tới HomeScreen...');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
          print('Đã gọi điều hướng.');
        } else {
          print('Widget không còn mounted, không điều hướng.');
        }
      } else {
        print('UserCredential.user là null sau khi đăng ký thành công? Điều này không nên xảy ra.');
        if (mounted) _showErrorDialog("Tạo tài khoản thành công nhưng không lấy được thông tin người dùng.");
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã có lỗi xảy ra khi đăng ký.";
      if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn (ít nhất 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Địa chỉ email này đã được sử dụng bởi tài khoản khác.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Địa chỉ email không hợp lệ.';
      }
      
      print('FirebaseAuthException khi đăng ký:');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('StackTrace: ${e.stackTrace}');
      if (mounted) _showErrorDialog(errorMessage);

    } catch (e, s) { // Bắt tất cả các lỗi khác và cả StackTrace
      print('Lỗi KHÔNG XÁC ĐỊNH khi đăng ký:');
      print('Error: $e');
      print('StackTrace: $s');
      if (mounted) _showErrorDialog("Đã có lỗi không mong muốn xảy ra trong quá trình đăng ký. Vui lòng thử lại.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Kết thúc xử lý _signupUser, _isLoading = false');
      }
    }
  }

  // Hàm hiển thị dialog thông báo lỗi
  void _showErrorDialog(String message) {
    if (!mounted) return; // Kiểm tra widget có còn trong cây widget không
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
    // Dọn dẹp controller khi widget bị hủy
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Ô nhập Email
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
                  enabled: !_isLoading, // Vô hiệu hóa khi đang loading
                ),
                const SizedBox(height: 20),
                // Ô nhập Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: !_isLoading, // Vô hiệu hóa khi đang loading
                ),
                const SizedBox(height: 20),
                // Ô nhập Xác nhận Mật khẩu
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    hintText: 'Nhập lại mật khẩu của bạn',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: !_isLoading, // Vô hiệu hóa khi đang loading
                ),
                const SizedBox(height: 30),
                // Nút Đăng ký (hiển thị loading nếu cần)
                _isLoading
                    ? const CircularProgressIndicator() // Hiển thị loading
                    : ElevatedButton(
                        onPressed: _signupUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50), // Nút rộng hết cỡ
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Đăng ký', style: TextStyle(fontSize: 18)),
                      ),
                const SizedBox(height: 20),
                // Chuyển sang màn hình Đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Đã có tài khoản?'),
                    TextButton(
                      onPressed: _isLoading ? null : () { // Vô hiệu hóa khi đang loading
                        // Điều hướng quay lại màn hình Đăng nhập
                        if (Navigator.canPop(context)) {
                           Navigator.pop(context);
                        }
                      },
                      child: const Text('Đăng nhập ngay'),
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