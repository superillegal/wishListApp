import 'package:flutter/foundation.dart';

@immutable
class Gift {
  final String id;
  final String title;          // идея подарка
  final String recipient;      // получатель
  final double? plannedPrice;  // бюджет/стоимость (опц.)
  final bool isPurchased;      // куплено/в планах
  final int priority;          // 1..5
  final DateTime dateAdded;
  final DateTime? datePurchased;
  final String? category;      // опц.
  final String? note;          // опц.

  const Gift({
    required this.id,
    required this.title,
    required this.recipient,
    required this.plannedPrice,
    required this.isPurchased,
    required this.priority,
    required this.dateAdded,
    required this.datePurchased,
    required this.category,
    required this.note,
  });

  Gift copyWith({
    String? id,
    String? title,
    String? recipient,
    double? plannedPrice,
    bool? isPurchased,
    int? priority,
    DateTime? dateAdded,
    DateTime? datePurchased,
    String? category,
    String? note,
  }) {
    return Gift(
      id: id ?? this.id,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      plannedPrice: plannedPrice ?? this.plannedPrice,
      isPurchased: isPurchased ?? this.isPurchased,
      priority: priority ?? this.priority,
      dateAdded: dateAdded ?? this.dateAdded,
      datePurchased: datePurchased ?? this.datePurchased,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  static Gift newDraft({
    required String title,
    required String recipient,
    double? plannedPrice,
    int priority = 3,
    String? category,
    String? note,
  }) {
    final now = DateTime.now();
    return Gift(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      recipient: recipient,
      plannedPrice: plannedPrice,
      isPurchased: false,
      priority: priority,
      dateAdded: now,
      datePurchased: null,
      category: category,
      note: note,
    );
  }
}
