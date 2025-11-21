import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../models/gift.dart';
import '../navigation/app_routes.dart';
import '../utils/format.dart';
import '../widgets/gift_image.dart';

class GiftDetailScreen extends StatelessWidget {
  final String giftId;

  const GiftDetailScreen({super.key, required this.giftId});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateInheritedWidget.of(context);
    if (appState == null) {
      return const Scaffold(
        body: Center(child: Text('AppState не найден')),
      );
    }

    final gift = appState.findGift(giftId);
    if (gift == null) {
      return const Scaffold(
        body: Center(child: Text('Подарок не найден')),
      );
    }

    final theme = Theme.of(context);
    final statusColor = gift.isPurchased ? Colors.green : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали подарка'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await context.push<Gift>(
                AppRoutePaths.giftEdit(gift.id),
              );
              if (!context.mounted) return;
              if (updated != null) {
                appState.onUpdateGift(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Сохранено')),
                );
              }
            },
          ),
          IconButton(
            tooltip: gift.isPurchased ? 'Вернуть в план' : 'Отметить купленным',
            icon: Icon(gift.isPurchased ? Icons.undo : Icons.check_circle_outline),
            onPressed: () => appState.onTogglePurchased(gift.id),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить подарок'),
                  content: Text('«${gift.title}» будет удален.'),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: const Text('Отмена')),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (ok == true) {
                await appState.onDeleteGift(gift.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          GiftHeaderImage(imageUrl: gift.imageUrl, title: gift.title),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.15),
                  statusColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  gift.isPurchased ? Icons.check_circle : Icons.pending_actions,
                  color: statusColor,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gift.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _InfoTile(label: 'Получатель', value: gift.recipient),
          _InfoTile(label: 'Категория', value: gift.category ?? '-'),
          _InfoTile(label: 'Статус', value: gift.isPurchased ? 'Куплен' : 'В планах'),
          _InfoTile(label: 'Приоритет', value: '${gift.priority} / 5'),
          _InfoTile(label: 'Бюджет', value: formatMoney(gift.plannedPrice)),
          _InfoTile(label: 'Добавлено', value: formatDate(gift.dateAdded)),
          _InfoTile(
            label: 'Дата покупки',
            value: gift.datePurchased == null ? '-' : formatDate(gift.datePurchased!),
          ),
          if (gift.note != null && gift.note!.trim().isNotEmpty)
            _InfoTile(label: 'Заметка', value: gift.note!),
          if (gift.imageUrl != null && gift.imageUrl!.trim().isNotEmpty)
            _InfoTile(label: 'Ссылка на картинку', value: gift.imageUrl!),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Оценить важность'),
              child: Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final filled = n <= gift.priority;
                  return IconButton(
                    onPressed: () => appState.onSetPriority(gift.id, n),
                    icon: Icon(filled ? Icons.star : Icons.star_border),
                    tooltip: '$n',
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(label, style: theme.textTheme.labelLarge),
      subtitle: Text(value),
    );
  }
}
