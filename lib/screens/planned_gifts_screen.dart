import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/gifts/bloc/gifts_bloc.dart';
import '../features/gifts/bloc/gifts_event.dart';
import '../features/gifts/bloc/gifts_state.dart';
import '../navigation/app_routes.dart';
import '../widgets/gift_tile.dart';


class PlannedGiftsScreen extends StatelessWidget {
  const PlannedGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GiftsBloc, GiftsState>(
      builder: (context, state) {
        if (state is! GiftsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final gifts = state.gifts.where((g) => !g.isPurchased).toList();

        if (gifts.isEmpty) {
          return const Center(child: Text('Нет запланированных подарков'));
        }
        return ListView.builder(
          itemCount: gifts.length,
          itemBuilder: (ctx, i) {
            final g = gifts[i];
            return GiftTile(
              gift: g,
              onTap: () => ctx.push(AppRoutePaths.giftDetails(g.id)),
              onDelete: () => context.read<GiftsBloc>().add(DeleteGift(g.id)),
              onTogglePurchased: () =>
                  context.read<GiftsBloc>().add(ToggleGiftPurchased(g.id, !g.isPurchased)),
              onSetPriority: (p) =>
                  context.read<GiftsBloc>().add(UpdateGiftPriority(g.id, p)),
            );
          },
        );
      },
    );
  }
}
