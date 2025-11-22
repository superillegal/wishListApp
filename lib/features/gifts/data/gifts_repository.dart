import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/gift.dart';
import '../../../services/image_service.dart';
import '../../../services/logger_service.dart';

/// Репозиторий подарков + лимита бюджета (Рисунки 26–28).
class GiftsRepository {
  GiftsRepository({required this.imageService});

  static const _keyGifts = 'gifts_store_v1';
  static const _keyBudget = 'budget_limit_v1';

  final ImageService imageService;

  Future<List<Gift>> getGifts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyGifts);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      LoggerService.error('GiftsRepository: error decode gifts $e');
      return [];
    }
  }

  Future<void> saveGifts(List<Gift> gifts) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(gifts.map((g) => g.toJson()).toList());
    await prefs.setString(_keyGifts, raw);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBudget) ?? 20000;
  }

  Future<void> saveBudgetLimit(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudget, value);
  }

  Future<Gift> ensureImage(Gift gift) async {
    if (gift.imageUrl != null && gift.imageUrl!.trim().isNotEmpty) return gift;
    try {
      final url = await imageService.nextImageUrl();
      return gift.copyWith(imageUrl: url);
    } catch (e) {
      LoggerService.warning('Не удалось загрузить изображение: $e');
      return gift;
    }
  }

  Future<void> releaseImage(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await imageService.releaseImage(url);
  }

  Future<List<Gift>> generateInitial() async {
    final templates = [
      (
        title: 'Настольная игра',
        recipient: 'Друзья',
        plannedPrice: 7500.0,
        priority: 5,
        category: 'Для компании'
      ),
      (
        title: 'Браслет',
        recipient: 'Сестра',
        plannedPrice: 4200.0,
        priority: 4,
        category: 'Украшения'
      ),
      (
        title: 'Книга про Flutter',
        recipient: 'Коллега',
        plannedPrice: 2200.0,
        priority: 5,
        category: 'Книги'
      ),
      (
        title: 'Фотосессия',
        recipient: 'Мама',
        plannedPrice: 3100.0,
        priority: 3,
        category: 'Впечатления'
      ),
      (
        title: 'Беспроводные наушники',
        recipient: 'Брат',
        plannedPrice: 5600.0,
        priority: 4,
        category: 'Гаджеты'
      ),
    ];

    final result = <Gift>[];
    for (final t in templates) {
      var gift = Gift.newDraft(
        title: t.title,
        recipient: t.recipient,
        plannedPrice: t.plannedPrice,
        priority: t.priority,
        category: t.category,
      );
      gift = await ensureImage(gift);
      result.add(gift);
    }
    await saveGifts(result);
    return result;
  }
}
