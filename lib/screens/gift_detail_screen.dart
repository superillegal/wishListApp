import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../utils/format.dart';
import 'gift_form_screen.dart';

class GiftDetailScreen extends StatelessWidget {
  final Gift gift;
  final void Function(Gift) onUpdate;
  final void Function(String id) onDelete;
  final void Function(String id) onTogglePurchased;
  final void Function(String id, int priority) onSetPriority;

  const GiftDetailScreen({
    super.key,
    required this.gift,
    required this.onUpdate,
    required this.onDelete,
    required this.onTogglePurchased,
    required this.onSetPriority,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = gift.isPurchased
        ? Colors.green
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали идеи'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.of(context).push<Gift>(
                MaterialPageRoute(builder: (_) => GiftFormScreen(initial: gift)),
              );
              if (updated != null) {
                onUpdate(updated);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Сохранено')),
                );
              }
            },
          ),
          IconButton(
            tooltip: gift.isPurchased ? 'Вернуть в планы' : 'Отметить купленным',
            icon: Icon(gift.isPurchased ? Icons.undo : Icons.check_circle_outline),
            onPressed: () => onTogglePurchased(gift.id),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить идею?'),
                  content: Text('«${gift.title}» будет удалена.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                onDelete(gift.id);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.15),
                  statusColor.withOpacity(0.05),
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
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _InfoTile(label: 'Получатель', value: gift.recipient),
          _InfoTile(label: 'Категория', value: gift.category ?? '—'),
          _InfoTile(label: 'Статус', value: gift.isPurchased ? 'Куплено' : 'В планах'),
          _InfoTile(label: 'Приоритет', value: '${gift.priority} / 5'),
          _InfoTile(label: 'Бюджет/цена', value: formatMoney(gift.plannedPrice)),
          _InfoTile(label: 'Добавлено', value: formatDate(gift.dateAdded)),
          _InfoTile(
              label: 'Дата покупки',
              value: gift.datePurchased == null ? '—' : formatDate(gift.datePurchased!)),
          if (gift.note != null && gift.note!.trim().isNotEmpty)
            _InfoTile(label: 'Заметка', value: gift.note!),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Изменить приоритет'),
              child: Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final filled = n <= gift.priority;
                  return IconButton(
                    onPressed: () => onSetPriority(gift.id, n),
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
