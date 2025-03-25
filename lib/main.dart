import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:electronics_shop_app/models/cart_item.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/views/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());
  
  // Open Hive boxes
  await Hive.openBox<CartItem>('cart');
  await Hive.openBox('settings');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
          seedColor: const Color.fromARGB(255, 235, 46, 140),
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFFE91E63),
          background: const Color.fromARGB(255, 243, 243, 243),
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
      home: const SplashScreen(),
    );
  }
}

