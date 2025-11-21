import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';
import 'models/gift.dart';
import 'navigation/app_routes.dart';
import 'screens/all_gifts_screen.dart';
import 'screens/gift_detail_screen.dart';
import 'screens/gift_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/planned_gifts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/purchased_gifts_screen.dart';
import 'services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  Services.image.preloadImagePool().catchError((e) {
    debugPrint('Image preload failed (maybe offline): $e');
  });

  runApp(const WishlistApp());
}

class WishlistApp extends StatefulWidget {
  const WishlistApp({super.key});

  @override
  State<WishlistApp> createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  late final GoRouter _router = _createRouter();

  List<Gift> _gifts = [];
  bool _isGeneratingInitial = false;
  double _budgetLimit = 20000;

  @override
  void initState() {
    super.initState();
    _generateInitialGifts();
  }

  GoRouter _createRouter() {
    return GoRouter(
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
              builder: (context, state) => const GiftFormScreen(),
            ),
            GoRoute(
              path: 'all',
              name: AppRouteNames.allGifts,
              builder: (context, state) => const _ModalListRoute(
                title: 'Все подарки',
                child: AllGiftsScreen(),
              ),
            ),
            GoRoute(
              path: 'purchased',
              name: AppRouteNames.purchasedGifts,
              builder: (context, state) => const _ModalListRoute(
                title: 'Купленные подарки',
                child: PurchasedGiftsScreen(),
              ),
            ),
            GoRoute(
              path: 'planned',
              name: AppRouteNames.plannedGifts,
              builder: (context, state) => const _ModalListRoute(
                title: 'В планах',
                child: PlannedGiftsScreen(),
              ),
            ),
            GoRoute(
              path: 'gifts/:id/edit',
              name: AppRouteNames.giftEdit,
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final appState = AppStateInheritedWidget.read(context);
                final gift = (id == null || appState == null) ? null : appState.findGift(id);
                if (gift == null) {
                  return const _RouteArgsError(message: 'Подарок не найден');
                }
                return GiftFormScreen(initial: gift);
              },
            ),
            GoRoute(
              path: 'gifts/:id',
              name: AppRouteNames.giftDetails,
              builder: (context, state) {
                final id = state.pathParameters['id'];
                if (id == null) {
                  return const _RouteArgsError(message: 'Некорректный идентификатор подарка');
                }
                return GiftDetailScreen(giftId: id);
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
  }

  Future<void> _generateInitialGifts() async {
    setState(() => _isGeneratingInitial = true);

    try {
      final templates = [
        (
          title: 'Робот-пылесос',
          recipient: 'Дом',
          plannedPrice: 7500.0,
          priority: 5,
          category: 'Бытовая техника'
        ),
        (
          title: 'Часы для тренировок',
          recipient: 'Друг',
          plannedPrice: 4200.0,
          priority: 4,
          category: 'Для спорта'
        ),
        (
          title: 'Книга по Flutter',
          recipient: 'Себе',
          plannedPrice: 2200.0,
          priority: 5,
          category: 'Учеба'
        ),
        (
          title: 'Настольная игра',
          recipient: 'Семья',
          plannedPrice: 3100.0,
          priority: 3,
          category: 'Отдых'
        ),
        (
          title: 'Bluetooth-наушники',
          recipient: 'Коллега',
          plannedPrice: 5600.0,
          priority: 4,
          category: 'Техника'
        ),
      ];

      final generated = <Gift>[];
      for (final t in templates) {
        String? imageUrl;
        try {
          imageUrl = await Services.image.nextImageUrl();
        } catch (e) {
          debugPrint('Не удалось получить изображение: $e');
        }
        generated.add(
          Gift.newDraft(
            title: t.title,
            recipient: t.recipient,
            plannedPrice: t.plannedPrice,
            priority: t.priority,
            category: t.category,
            imageUrl: imageUrl,
          ),
        );
      }
      if (!mounted) return;
      setState(() => _gifts = generated);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingInitial = false);
      } else {
        _isGeneratingInitial = false;
      }
    }
  }

  Future<void> _addGift(Gift gift) async {
    String? imageUrl = gift.imageUrl;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      try {
        imageUrl = await Services.image.nextImageUrl();
      } catch (e) {
        debugPrint('Не удалось получить изображение: $e');
      }
    }
    final withImage = (imageUrl == null) ? gift : gift.copyWith(imageUrl: imageUrl);
    setState(() => _gifts = [withImage, ..._gifts]);
  }

  void _updateGift(Gift gift) {
    final index = _gifts.indexWhere((g) => g.id == gift.id);
    if (index == -1) return;
    final updated = [..._gifts]..[index] = gift;
    setState(() => _gifts = updated);
  }

  Future<void> _deleteGift(String id) async {
    Gift? toRemove;
    for (final gift in _gifts) {
      if (gift.id == id) {
        toRemove = gift;
        break;
      }
    }

    if (toRemove?.imageUrl != null) {
      await Services.image.releaseImage(toRemove!.imageUrl!);
    }

    setState(() => _gifts = _gifts.where((g) => g.id != id).toList());
  }

  void _togglePurchased(String id) {
    final index = _gifts.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final gift = _gifts[index];
    final toggled = gift.copyWith(
      isPurchased: !gift.isPurchased,
      datePurchased: !gift.isPurchased ? DateTime.now() : null,
    );
    final updated = [..._gifts]..[index] = toggled;
    setState(() => _gifts = updated);
  }

  void _setPriority(String id, int priority) {
    final index = _gifts.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final updated = [..._gifts];
    updated[index] = updated[index].copyWith(priority: priority);
    setState(() => _gifts = updated);
  }

  void _changeBudgetLimit(double limit) {
    setState(() => _budgetLimit = limit);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1E88E5),
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    );

    return AppStateInheritedWidget(
      gifts: _gifts,
      isGeneratingInitial: _isGeneratingInitial,
      budgetLimit: _budgetLimit,
      onAddGift: _addGift,
      onUpdateGift: _updateGift,
      onDeleteGift: _deleteGift,
      onTogglePurchased: _togglePurchased,
      onSetPriority: _setPriority,
      onChangeBudgetLimit: _changeBudgetLimit,
      imageService: Services.image,
      child: MaterialApp.router(
        title: 'Wishlist Gifts',
        theme: baseTheme.copyWith(
          appBarTheme: const AppBarTheme(centerTitle: true),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

class _ModalListRoute extends StatelessWidget {
  final String title;
  final Widget child;

  const _ModalListRoute({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

class _RouteArgsError extends StatelessWidget {
  final String message;
  const _RouteArgsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка аргументов')),
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
