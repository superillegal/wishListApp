import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wishlist/main.dart';
import 'package:wishlist/services/service_locator.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupServiceLocator();
  });

  testWidgets('Login screen renders through WishlistApp', (tester) async {
    await tester.pumpWidget(const WishlistApp());
    await tester.pumpAndSettle();

    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
