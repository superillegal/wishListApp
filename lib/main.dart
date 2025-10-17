import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WishlistApp());
}

class WishlistApp extends StatelessWidget {
  const WishlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1E88E5),
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      title: 'Wishlist подарков',
      theme: baseTheme.copyWith(
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
