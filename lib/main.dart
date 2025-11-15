import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/gift.dart';
import 'screens/all_gifts_screen.dart';
import 'screens/gift_detail_screen.dart';
import 'screens/gift_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/planned_gifts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/purchased_gifts_screen.dart';
import 'services/image_service.dart';
import 'navigation/app_routes.dart';
import 'navigation/route_args.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final imageService = ImageService.instance;
  await imageService.initialize();
  imageService.preloadImagePool().catchError((e) {
    debugPrint('Предзагрузка обложек не удалась: $e');
  });

  final router = GoRouter(
    initialLocation: AppRoutePaths.login,
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.home,
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'gifts/new',
            name: AppRouteNames.giftForm,
            builder: (context, state) {
              final initial = state.extra;
              return GiftFormScreen(initial: initial is Gift ? initial : null);
            },
          ),
          GoRoute(
            path: 'all',
            name: AppRouteNames.allGifts,
            builder: (context, state) => _ModalListRoute(
              args: state.extra,
              fallbackTitle: 'Все подарки',
              builder: (args) => AllGiftsScreen(
                gifts: args.gifts,
                onOpen: args.onOpen,
                onDelete: args.onDelete,
                onTogglePurchased: args.onTogglePurchased,
                onSetPriority: args.onSetPriority,
              ),
            ),
          ),
          GoRoute(
            path: 'purchased',
            name: AppRouteNames.purchasedGifts,
            builder: (context, state) => _ModalListRoute(
              args: state.extra,
              fallbackTitle: 'Купленные подарки',
              builder: (args) => PurchasedGiftsScreen(
                gifts: args.gifts,
                onOpen: args.onOpen,
                onDelete: args.onDelete,
                onTogglePurchased: args.onTogglePurchased,
                onSetPriority: args.onSetPriority,
              ),
            ),
          ),
          GoRoute(
            path: 'planned',
            name: AppRouteNames.plannedGifts,
            builder: (context, state) => _ModalListRoute(
              args: state.extra,
              fallbackTitle: 'Подарки в ожидании',
              builder: (args) => PlannedGiftsScreen(
                gifts: args.gifts,
                onOpen: args.onOpen,
                onDelete: args.onDelete,
                onTogglePurchased: args.onTogglePurchased,
                onSetPriority: args.onSetPriority,
              ),
            ),
          ),
          GoRoute(
            path: 'gifts/:id/edit',
            name: AppRouteNames.giftEdit,
            builder: (context, state) {
              final initial = state.extra;
              if (initial is! Gift) {
                return const _RouteArgsError(
                  message: 'Для редактирования требуется передать Gift',
                );
              }
              return GiftFormScreen(initial: initial);
            },
          ),
          GoRoute(
            path: 'gifts/:id',
            name: AppRouteNames.giftDetails,
            builder: (context, state) {
              final args = state.extra;
              if (args is! GiftDetailRouteArgs) {
                return const _RouteArgsError(
                  message: 'Ожидается GiftDetailRouteArgs для экрана деталей подарка',
                );
              }
              return GiftDetailScreen(
                gift: args.gift,
                onUpdate: args.onUpdate,
                onDelete: args.onDelete,
                onTogglePurchased: args.onTogglePurchased,
                onSetPriority: args.onSetPriority,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );

  runApp(WishlistApp(router: router));
}

class WishlistApp extends StatelessWidget {
  final GoRouter router;

  const WishlistApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1E88E5),
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    );
    return MaterialApp.router(
      title: 'Wishlist Подарков',
      theme: baseTheme.copyWith(
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

class _ModalListRoute extends StatelessWidget {
  final Object? args;
  final String fallbackTitle;
  final Widget Function(GiftListRouteArgs args) builder;

  const _ModalListRoute({
    required this.args,
    required this.fallbackTitle,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final data = args;
    if (data is! GiftListRouteArgs) {
      return _RouteArgsError(
        message:
            'Ожидается GiftListRouteArgs для маршрута "$fallbackTitle", но получено ${data.runtimeType}',
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(data.title.isEmpty ? fallbackTitle : data.title)),
      body: builder(data),
    );
  }
}

class _RouteArgsError extends StatelessWidget {
  final String message;
  const _RouteArgsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка маршрута')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
