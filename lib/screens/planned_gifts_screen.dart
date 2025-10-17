import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../widgets/gift_tile.dart';

class PlannedGiftsScreen extends StatelessWidget {
  final List<Gift> gifts;
  final void Function(Gift gift) onOpen;
  final void Function(String id) onDelete;
  final void Function(String id) onTogglePurchased;
  final void Function(String id, int priority) onSetPriority;

  const PlannedGiftsScreen({
    super.key,
    required this.gifts,
    required this.onOpen,
    required this.onDelete,
    required this.onTogglePurchased,
    required this.onSetPriority,
  });

  @override
  Widget build(BuildContext context) {
    if (gifts.isEmpty) {
      return const Center(child: Text('Пока нет запланированных идей'));
    }
    return ListView.builder(
      itemCount: gifts.length,
      itemBuilder: (ctx, i) {
        final g = gifts[i];
        return GiftTile(
          gift: g,
          onTap: () => onOpen(g),
          onDelete: () => onDelete(g.id),
          onTogglePurchased: () => onTogglePurchased(g.id),
          onSetPriority: (p) => onSetPriority(g.id, p),
        );
      },
    );
  }
}
