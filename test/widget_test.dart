// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/main.dart';
import 'package:wishlist/navigation/app_routes.dart';
import 'package:wishlist/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders through WishlistApp', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutePaths.login,
      routes: [
        GoRoute(
          path: AppRoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    await tester.pumpWidget(WishlistApp(router: router));

    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Авторизуйтесь, чтобы управлять подарками'), findsOneWidget);
  });
}
