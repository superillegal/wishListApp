import '../models/gift.dart';

class GiftListRouteArgs {
  final String title;
  final List<Gift> gifts;
  final void Function(Gift gift) onOpen;
  final void Function(String id) onDelete;
  final void Function(String id) onTogglePurchased;
  final void Function(String id, int priority) onSetPriority;

  const GiftListRouteArgs({
    required this.title,
    required this.gifts,
    required this.onOpen,
    required this.onDelete,
    required this.onTogglePurchased,
    required this.onSetPriority,
  });
}

class GiftDetailRouteArgs {
  final Gift gift;
  final void Function(Gift gift) onUpdate;
  final void Function(String id) onDelete;
  final void Function(String id) onTogglePurchased;
  final void Function(String id, int priority) onSetPriority;

  const GiftDetailRouteArgs({
    required this.gift,
    required this.onUpdate,
    required this.onDelete,
    required this.onTogglePurchased,
    required this.onSetPriority,
  });
}
