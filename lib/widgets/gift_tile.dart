import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../utils/format.dart';

class GiftTile extends StatelessWidget {
  final Gift gift;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePurchased;
  final ValueChanged<int> onSetPriority;

  const GiftTile({
    super.key,
    required this.gift,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePurchased,
    required this.onSetPriority,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = <String>[
      gift.recipient,
      if (gift.category != null && gift.category!.trim().isNotEmpty)
        gift.category!,
      if (gift.plannedPrice != null) formatMoney(gift.plannedPrice),
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          gift.isPurchased ? Icons.check_circle : Icons.pending_outlined,
          color: gift.isPurchased ? Colors.green : theme.colorScheme.primary,
        ),
        title: Text(gift.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PriorityDots(
              value: gift.priority,
              onChanged: onSetPriority,
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    onTogglePurchased();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(gift.isPurchased ? 'Вернуть в планы' : 'Отметить купленным'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Удалить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityDots extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PriorityDots({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final filled = n <= value;
        return InkWell(
          onTap: () => onChanged(n),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              size: 20,
            ),
          ),
        );
      }),
    );
  }
}
