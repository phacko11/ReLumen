
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('MAIN: Initializing Firebase...');
  try {
    await Firebase.initializeApp();
    print('MAIN: Firebase initialized SUCCESSFULLY!');
    runApp(const MyApp());
    print('MAIN: runApp(const MyApp()) called.');
  } catch (e, stackTrace) {
    print('MAIN: CRITICAL ERROR Initializing Firebase:');
    print('Error: $e');
    print('StackTrace: $stackTrace');
    runApp(ErrorApp(errorMessage: e.toString()));
    print('MAIN: runApp(ErrorApp()) due to Firebase init error.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp build() called.');

    const Color darkOrange = Color(0xFFF57C00);

    return MaterialApp(
      title: 'ReLumen',
      debugShowCheckedModeBanner: false, // Optionally hide the debug banner

      // --- Define the theme here ---
      theme: ThemeData(
        useMaterial3: true, // Recommended for new Flutter apps

        // Define the color scheme using a seed color for Material 3
        // This will generate a harmonious palette.
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkOrange,
          brightness: Brightness.light, // Ensures light theme (e.g., white backgrounds)
          // You can override specific colors if needed:
          // primary: darkOrange,
          // secondary: Colors.orangeAccent, // Example secondary color
          // background: Colors.white,
          // surface: Colors.white, // For cards, dialogs, etc.
          // onPrimary: Colors.white, // Text/icons on primary color
          // onBackground: Colors.black87, // Text/icons on background color
        ),

        // Scaffold background color - often handled by ColorScheme with Brightness.light,
        // but can be set explicitly.
        scaffoldBackgroundColor: Colors.white,

        // Customize AppBar theme (optional, ColorScheme might handle it well)
        appBarTheme: const AppBarTheme(
          backgroundColor: darkOrange, // AppBar background
          foregroundColor: Colors.white, // Text and icons on AppBar
          elevation: 2.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600, // Changed from bold to w600
            color: Colors.white,
          ),
        ),

        // Customize ElevatedButton theme (optional)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkOrange, // Button background
            foregroundColor: Colors.white, // Button text/icon color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners for buttons
            ),
          ),
        ),
        
        // Customize FloatingActionButton theme (optional)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkOrange,
          foregroundColor: Colors.white,
        ),

        // Customize Card theme (optional)
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        ),

        // Customize TextField input decoration theme (optional)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: darkOrange, width: 2.0),
          ),
          labelStyle: const TextStyle(color: darkOrange),
          // hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        
        // You can customize other components like TextButton, BottomAppBar, etc.
        // textButtonTheme: TextButtonThemeData(
        //   style: TextButton.styleFrom(foregroundColor: darkOrange)
        // ),

        // Ensure visual density is adaptive
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // ------------------------------

      home: AuthWrapper(), // Your AuthWrapper handles initial screen logic
    );
  }
}

// ErrorApp widget (assuming it's defined as before)
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Could not start the application.\nFirebase Error: $errorMessage',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}