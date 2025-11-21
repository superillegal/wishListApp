import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/gift.dart';
import 'services/image_service.dart';

class AppStateInheritedWidget extends InheritedWidget {
  final List<Gift> gifts;
  final bool isGeneratingInitial;
  final double budgetLimit;

  final Future<void> Function(Gift gift) onAddGift;
  final void Function(Gift gift) onUpdateGift;
  final Future<void> Function(String id) onDeleteGift;
  final void Function(String id) onTogglePurchased;
  final void Function(String id, int priority) onSetPriority;
  final void Function(double limit) onChangeBudgetLimit;

  final ImageService imageService;

  const AppStateInheritedWidget({
    super.key,
    required super.child,
    required this.gifts,
    required this.isGeneratingInitial,
    required this.budgetLimit,
    required this.onAddGift,
    required this.onUpdateGift,
    required this.onDeleteGift,
    required this.onTogglePurchased,
    required this.onSetPriority,
    required this.onChangeBudgetLimit,
    required this.imageService,
  });

  static AppStateInheritedWidget? of(BuildContext context) {е
    return context.dependOnInheritedWidgetOfExactType<AppStateInheritedWidget>();
  }

  static AppStateInheritedWidget? read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppStateInheritedWidget>();
  }

  @override
  bool updateShouldNotify(AppStateInheritedWidget oldWidget) {
    return !listEquals(gifts, oldWidget.gifts) ||
        isGeneratingInitial != oldWidget.isGeneratingInitial ||
        budgetLimit != oldWidget.budgetLimit ||
        imageService != oldWidget.imageService;
  }

  int get totalGifts => gifts.length;
  int get purchasedCount => gifts.where((g) => g.isPurchased).length;
  int get plannedCount => totalGifts - purchasedCount;

  double get spent =>
      gifts.where((g) => g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));

  double get planned =>
      gifts.where((g) => !g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));

  List<Gift> get recentGifts {
    final sorted = [...gifts]..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(5).toList();
  }

  Gift? findGift(String id) {
    for (final gift in gifts) {
      if (gift.id == id) return gift;
    }
    return null;
  }
}
