import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/gifts/bloc/gifts_bloc.dart';
import '../features/gifts/bloc/gifts_event.dart';
import '../features/gifts/bloc/gifts_state.dart';
import '../models/gift.dart';
import '../navigation/app_routes.dart';
import '../utils/format.dart';
import '../widgets/gift_image.dart';


class GiftDetailScreen extends StatelessWidget {
  final String giftId;

  const GiftDetailScreen({super.key, required this.giftId});

  Gift? _findGift(BuildContext context) {
    final state = context.read<GiftsBloc>().state;
    if (state is! GiftsLoaded) return null;
    try {
      return state.gifts.firstWhere((g) => g.id == giftId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GiftsBloc, GiftsState>(
      builder: (context, state) {
        if (state is! GiftsLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final gift = _findGift(context);
        if (gift == null) {
          return const Scaffold(
            body: Center(child: Text('Подарок не найден')),
          );
        }

        final statusColor = gift.isPurchased ? Colors.green : theme.colorScheme.primary;

        return Scaffold(
          appBar: AppBar(
            title: Text(gift.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                    context.read<GiftsBloc>().add(UpdateGift(updated));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сохранено')),
                    );
                  }
                },
              ),
              IconButton(
                tooltip: gift.isPurchased ? 'Вернуть в план' : 'Отметить купленным',
                icon: Icon(gift.isPurchased ? Icons.undo : Icons.check_circle_outline),
                onPressed: () => context
                    .read<GiftsBloc>()
                    .add(ToggleGiftPurchased(gift.id, !gift.isPurchased)),
              ),
              IconButton(
                tooltip: 'Удалить',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Удалить подарок'),
                      content: Text('“${gift.title}” будет удалён.'),
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
                    context.read<GiftsBloc>().add(DeleteGift(gift.id));
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = (constraints.maxHeight * 0.35).clamp(180.0, 280.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: imageHeight,
                        child: GiftHeaderImage(imageUrl: gift.imageUrl, title: gift.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  gift.isPurchased ? Icons.check_circle : Icons.pending_actions,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gift.isPurchased ? 'Куплено' : 'В планах',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Spacer(),
                                _PriorityStars(
                                  value: gift.priority,
                                  onTap: (v) => context
                                      .read<GiftsBloc>()
                                      .add(UpdateGiftPriority(gift.id, v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.person_outline, label: 'Получатель', value: gift.recipient),
                            _InfoRow(
                              icon: Icons.category_outlined,
                              label: 'Категория',
                              value: gift.category ?? 'Без категории',
                            ),
                            _InfoRow(
                              icon: Icons.attach_money,
                              label: 'Бюджет',
                              value: formatMoney(gift.plannedPrice),
                            ),
                            _InfoRow(
                              icon: Icons.event_available,
                              label: 'Добавлено',
                              value: formatDate(gift.dateAdded),
                            ),
                            _InfoRow(
                              icon: Icons.event,
                              label: 'Покупка',
                              value: gift.datePurchased == null
                                  ? '-'
                                  : formatDate(gift.datePurchased!),
                            ),
                            if (gift.note != null && gift.note!.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Комментарий', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text(gift.note!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (gift.imageUrl != null && gift.imageUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Ссылка на изображение', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(gift.imageUrl!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<GiftsBloc>()
                          .add(ToggleGiftPurchased(gift.id, !gift.isPurchased)),
                      icon: Icon(gift.isPurchased ? Icons.undo : Icons.check),
                      label: Text(gift.isPurchased ? 'Вернуть в план' : 'Отметить купленным'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityStars extends StatelessWidget {
  final int value;
  final ValueChanged<int> onTap;

  const _PriorityStars({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final filled = n <= value;
        return IconButton(
          onPressed: () => onTap(n),
          icon: Icon(filled ? Icons.star : Icons.star_border),
          color: filled ? Theme.of(context).colorScheme.primary : null,
          tooltip: '$n',
        );
      }),
    );
  }
}
