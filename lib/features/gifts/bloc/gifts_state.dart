import 'package:equatable/equatable.dart';

import '../../../models/gift.dart';

abstract class GiftsState extends Equatable {
  const GiftsState();

  @override
  List<Object?> get props => [];
}

class GiftsInitial extends GiftsState {
  const GiftsInitial();
}

class GiftsLoading extends GiftsState {
  const GiftsLoading();
}

class GiftsError extends GiftsState {
  final String message;
  const GiftsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GiftsLoaded extends GiftsState {
  final List<Gift> gifts;
  final double budgetLimit;

  const GiftsLoaded(this.gifts, this.budgetLimit);

  @override
  List<Object?> get props => [gifts, budgetLimit];

  int get totalGifts => gifts.length;
  int get purchasedCount => gifts.where((g) => g.isPurchased).length;
  int get plannedCount => totalGifts - purchasedCount;

  double get spent =>
      gifts.where((g) => g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));

  double get planned =>
      gifts.where((g) => !g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));

  double get progressPercent => budgetLimit == 0 ? 0 : (spent / budgetLimit).clamp(0, 1);

  List<Gift> get recentGifts {
    final sorted = [...gifts]..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(5).toList();
  }

  List<Gift> get purchasedGifts => gifts.where((g) => g.isPurchased).toList();
  List<Gift> get plannedGifts => gifts.where((g) => !g.isPurchased).toList();

  Map<String, int> get categories {
    final map = <String, int>{};
    for (final g in gifts) {
      final cat = g.category ?? 'Без категории';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }
}
