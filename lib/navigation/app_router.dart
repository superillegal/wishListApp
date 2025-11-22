import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/gifts/bloc/gifts_bloc.dart';
import '../features/gifts/bloc/gifts_state.dart';
import '../models/gift.dart';
import '../screens/all_gifts_screen.dart';
import '../screens/gift_detail_screen.dart';
import '../screens/gift_form_screen.dart';
import '../screens/home_screen.dart';
import '../screens/planned_gifts_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/purchased_gifts_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({required this.authBloc});

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutePaths.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final loggedIn = authState is Authenticated;
      final loggingIn = state.matchedLocation == AppRoutePaths.login;

      if (!loggedIn && !loggingIn) return AppRoutePaths.login;
      if (loggedIn && loggingIn) return AppRoutePaths.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const AuthScreen(),
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
              if (id == null) return const _RouteArgsError(message: 'Подарок не найден');
              final giftsState = context.read<GiftsBloc>().state;
              if (giftsState is! GiftsLoaded) {
                return const _RouteArgsError(message: 'Данные ещё не загружены');
              }
              Gift? gift;
              for (final g in giftsState.gifts) {
                if (g.id == id) {
                  gift = g;
                  break;
                }
              }
              if (gift == null) return const _RouteArgsError(message: 'Подарок не найден');
              return GiftFormScreen(initial: gift, key: ValueKey('edit-$id'));
            },
          ),
          GoRoute(
            path: 'gifts/:id',
            name: AppRouteNames.giftDetails,
            builder: (context, state) {
              final id = state.pathParameters['id'];
              if (id == null) {
                return const _RouteArgsError(message: 'Не указан id подарка');
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

// Локальный слушатель стрима Bloc для refresh go_router.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
