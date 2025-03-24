import 'package:flutter/material.dart';
import 'package:electronics_shop_app/views/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFFE91E63),
          background: const Color(0xFFFCE4EC),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCE4EC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCE4EC),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        useMaterial3: true,
      ), 
      home: const OnboardingScreen(),
    );
  }
}
