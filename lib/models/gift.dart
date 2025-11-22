import 'package:flutter/foundation.dart';

@immutable
class Gift {
  final String id;
  final String title; // имя подарка
  final String recipient; // получатель
  final double? plannedPrice; // план/факт (руб.)
  final bool isPurchased; // куплен/в планах
  final int priority; // 1..5
  final DateTime dateAdded;
  final DateTime? datePurchased;
  final String? category; // кат.
  final String? note; // прим.
  final String? imageUrl; // картинка

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
    required this.imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'recipient': recipient,
      'plannedPrice': plannedPrice,
      'isPurchased': isPurchased,
      'priority': priority,
      'dateAdded': dateAdded.toIso8601String(),
      'datePurchased': datePurchased?.toIso8601String(),
      'category': category,
      'note': note,
      'imageUrl': imageUrl,
    };
  }

  static Gift fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] as String,
      title: json['title'] as String,
      recipient: json['recipient'] as String,
      plannedPrice: (json['plannedPrice'] as num?)?.toDouble(),
      isPurchased: json['isPurchased'] as bool? ?? false,
      priority: json['priority'] as int? ?? 3,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      datePurchased: json['datePurchased'] == null
          ? null
          : DateTime.parse(json['datePurchased'] as String),
      category: json['category'] as String?,
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static Gift newDraft({
    required String title,
    required String recipient,
    double? plannedPrice,
    int priority = 3,
    String? category,
    String? note,
    String? imageUrl,
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
      imageUrl: imageUrl,
    );
  }
}
