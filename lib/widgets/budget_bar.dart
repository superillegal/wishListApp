import 'package:flutter/material.dart';
import '../utils/format.dart';

class BudgetBar extends StatelessWidget {
  final double limit;
  final double spent;

  const BudgetBar({
    super.key,
    required this.limit,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (limit <= 0) ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final over = spent > limit;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Бюджет',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Потрачено: ${formatMoney(spent)}'),
                Text('Лимит: ${formatMoney(limit)}',
                    style: TextStyle(
                        color: over
                            ? theme.colorScheme.error
                            : theme.textTheme.bodyMedium?.color)),
              ],
            ),
            if (over) ...[
              const SizedBox(height: 8),
              Text(
                'Внимание: перерасход на ${formatMoney(spent - limit)}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
