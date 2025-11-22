import 'package:equatable/equatable.dart';

import '../../../models/gift.dart';

abstract class GiftsEvent extends Equatable {
  const GiftsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGifts extends GiftsEvent {
  const LoadGifts();
}

class AddGift extends GiftsEvent {
  final Gift gift;
  const AddGift(this.gift);

  @override
  List<Object?> get props => [gift];
}

class UpdateGift extends GiftsEvent {
  final Gift gift;
  const UpdateGift(this.gift);

  @override
  List<Object?> get props => [gift];
}

class DeleteGift extends GiftsEvent {
  final String id;
  const DeleteGift(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleGiftPurchased extends GiftsEvent {
  final String id;
  final bool isPurchased;
  const ToggleGiftPurchased(this.id, this.isPurchased);

  @override
  List<Object?> get props => [id, isPurchased];
}

class UpdateGiftPriority extends GiftsEvent {
  final String id;
  final int priority;
  const UpdateGiftPriority(this.id, this.priority);

  @override
  List<Object?> get props => [id, priority];
}

class ChangeBudgetLimit extends GiftsEvent {
  final double limit;
  const ChangeBudgetLimit(this.limit);

  @override
  List<Object?> get props => [limit];
}
