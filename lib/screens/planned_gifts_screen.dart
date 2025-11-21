import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../navigation/app_routes.dart';
import '../widgets/gift_tile.dart';

class PlannedGiftsScreen extends StatelessWidget {
  const PlannedGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateInheritedWidget.of(context);
    if (appState == null) {
      return const Center(child: Text('AppState не найден'));
    }

    final gifts = appState.gifts.where((g) => !g.isPurchased).toList();

    if (gifts.isEmpty) {
      return const Center(child: Text('Пока нет запланированных подарков'));
    }
    return ListView.builder(
      itemCount: gifts.length,
      itemBuilder: (ctx, i) {
        final g = gifts[i];
        return GiftTile(
          gift: g,
          onTap: () => ctx.push(AppRoutePaths.giftDetails(g.id)),
          onDelete: () => appState.onDeleteGift(g.id),
          onTogglePurchased: () => appState.onTogglePurchased(g.id),
          onSetPriority: (p) => appState.onSetPriority(g.id, p),
        );
      },
    );
  }
}
