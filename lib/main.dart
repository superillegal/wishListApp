import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/home_screen.dart';
import 'services/image_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final imageService = ImageService.instance;
  await imageService.initialize();
  imageService.preloadImagePool().catchError((e) {
    debugPrint('Предзагрузка обложек не удалась: $e');
  });
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
