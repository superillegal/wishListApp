import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/gift.dart';
import '../../../services/logger_service.dart';
import '../data/gifts_repository.dart';
import 'gifts_event.dart';
import 'gifts_state.dart';

class GiftsBloc extends Bloc<GiftsEvent, GiftsState> {
  final GiftsRepository _repository;

  GiftsBloc({required GiftsRepository repository})
      : _repository = repository,
        super(const GiftsInitial()) {
    on<LoadGifts>(_onLoadGifts);
    on<AddGift>(_onAddGift);
    on<UpdateGift>(_onUpdateGift);
    on<DeleteGift>(_onDeleteGift);
    on<ToggleGiftPurchased>(_onToggleGiftPurchased);
    on<UpdateGiftPriority>(_onUpdateGiftPriority);
    on<ChangeBudgetLimit>(_onChangeBudgetLimit);
  }

  Future<void> _onLoadGifts(LoadGifts event, Emitter<GiftsState> emit) async {
    emit(const GiftsLoading());
    try {
      final gifts = await _repository.getGifts();
      final budget = await _repository.getBudgetLimit();
      if (gifts.isEmpty) {
        final generated = await _repository.generateInitial();
        emit(GiftsLoaded(generated, budget));
        LoggerService.info('Gifts: сгенерированы стартовые ${generated.length} шт.');
      } else {
        emit(GiftsLoaded(gifts, budget));
        LoggerService.info('Gifts: загружено ${gifts.length}');
      }
    } catch (e) {
      LoggerService.error('Gifts: ошибка загрузки $e');
      emit(GiftsError('Не удалось загрузить подарки: $e'));
    }
  }

  Future<void> _onAddGift(AddGift event, Emitter<GiftsState> emit) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    try {
      final giftWithImage = await _repository.ensureImage(event.gift);
      final updated = [giftWithImage, ...current.gifts];
      await _repository.saveGifts(updated);
      emit(GiftsLoaded(updated, current.budgetLimit));
    } catch (e) {
      emit(GiftsError('Не удалось добавить подарок: $e'));
    }
  }

  Future<void> _onUpdateGift(UpdateGift event, Emitter<GiftsState> emit) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    final index = current.gifts.indexWhere((g) => g.id == event.gift.id);
    if (index == -1) return;
    final list = [...current.gifts]..[index] = event.gift;
    await _repository.saveGifts(list);
    emit(GiftsLoaded(list, current.budgetLimit));
  }

  Future<void> _onDeleteGift(DeleteGift event, Emitter<GiftsState> emit) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    Gift? toRemove;
    for (final gift in current.gifts) {
      if (gift.id == event.id) {
        toRemove = gift;
        break;
      }
    }
    final list = current.gifts.where((g) => g.id != event.id).toList();
    await _repository.releaseImage(toRemove?.imageUrl);
    await _repository.saveGifts(list);
    emit(GiftsLoaded(list, current.budgetLimit));
  }

  Future<void> _onToggleGiftPurchased(
    ToggleGiftPurchased event,
    Emitter<GiftsState> emit,
  ) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    final index = current.gifts.indexWhere((g) => g.id == event.id);
    if (index == -1) return;
    final updatedGift = current.gifts[index].copyWith(
      isPurchased: event.isPurchased,
      datePurchased: event.isPurchased ? DateTime.now() : null,
    );
    final list = [...current.gifts]..[index] = updatedGift;
    await _repository.saveGifts(list);
    emit(GiftsLoaded(list, current.budgetLimit));
  }

  Future<void> _onUpdateGiftPriority(
    UpdateGiftPriority event,
    Emitter<GiftsState> emit,
  ) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    final index = current.gifts.indexWhere((g) => g.id == event.id);
    if (index == -1) return;
    final list = [...current.gifts];
    list[index] = list[index].copyWith(priority: event.priority);
    await _repository.saveGifts(list);
    emit(GiftsLoaded(list, current.budgetLimit));
  }

  Future<void> _onChangeBudgetLimit(
    ChangeBudgetLimit event,
    Emitter<GiftsState> emit,
  ) async {
    if (state is! GiftsLoaded) return;
    final current = state as GiftsLoaded;
    await _repository.saveBudgetLimit(event.limit);
    emit(GiftsLoaded(current.gifts, event.limit));
  }
}
