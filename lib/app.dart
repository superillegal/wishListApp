import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/gifts/bloc/gifts_bloc.dart';
import 'features/gifts/bloc/gifts_event.dart';
import 'features/profile/bloc/profile_cubit.dart';
import 'features/theme/bloc/theme_cubit.dart';
import 'features/theme/bloc/theme_state.dart';
import 'navigation/app_router.dart';
import 'services/service_locator.dart';

class WishlistApp extends StatefulWidget {
  const WishlistApp({super.key});

  @override
  State<WishlistApp> createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  late final AuthBloc _authBloc;
  late final GiftsBloc _giftsBloc;
  late final ProfileCubit _profileCubit;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authService: Services.auth)..add(const CheckAccount());
    _giftsBloc = GiftsBloc(repository: Services.gifts)..add(const LoadGifts());
    _profileCubit = ProfileCubit(profileService: Services.profile)..loadProfile();
    _themeCubit = ThemeCubit()..loadTheme();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _giftsBloc.close();
    _profileCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<GiftsBloc>.value(value: _giftsBloc),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final themeMode = themeState is ThemeLoaded ? themeState.themeMode : ThemeMode.light;
          final baseTheme = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF1E88E5),
            brightness: Brightness.light,
            fontFamily: 'Roboto',
          );
          return MaterialApp.router(
            title: 'Wishlist Gifts',
            theme: baseTheme.copyWith(
              appBarTheme: const AppBarTheme(centerTitle: true),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF1E88E5),
              brightness: Brightness.dark,
            ),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
