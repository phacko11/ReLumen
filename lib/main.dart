import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Đang chuẩn bị khởi tạo Firebase...'); // Log_1

  try {
    await Firebase.initializeApp();
    print('Firebase đã khởi tạo THÀNH CÔNG!'); // Log_2
    runApp(const MyApp()); 
    print('Đã gọi runApp(const MyApp())'); // Log_3
  } catch (e, stackTrace) {

    print('LỖI NGHIÊM TRỌNG KHI KHỞI TẠO FIREBASE:'); // Log_Error_1
    print('Error: $e'); // Log_Error_2
    print('StackTrace: $stackTrace'); // Log_Error_3

    runApp(ErrorApp(errorMessage: e.toString()));
    print('Đã gọi runApp(ErrorApp()) do có lỗi Firebase'); // Log_Error_4

  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    print('MyApp build() được gọi.'); 
    return MaterialApp(
      title: 'ReLumen',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(), 
    );
  }
}
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    print('ErrorApp build() được gọi với lỗi: $errorMessage');
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Không thể khởi động ứng dụng.\nLỗi Firebase: $errorMessage',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}