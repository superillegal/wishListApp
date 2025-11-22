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


class GiftDetailScreen extends StatefulWidget {
  final String giftId;

  const GiftDetailScreen({super.key, required this.giftId});

  @override
  State<GiftDetailScreen> createState() => _GiftDetailScreenState();
}

class _GiftDetailScreenState extends State<GiftDetailScreen> {
  Gift? _gift;

  @override
  void initState() {
    super.initState();
    _loadGift();
  }

  void _loadGift() {
    final state = context.read<GiftsBloc>().state;
    if (state is GiftsLoaded) {
      for (final g in state.gifts) {
        if (g.id == widget.giftId) {
          _gift = g;
          break;
        }
      }
    }
  }

  void _togglePurchased() {
    if (_gift == null) return;
    final nextValue = !_gift!.isPurchased;
    context.read<GiftsBloc>().add(ToggleGiftPurchased(_gift!.id, nextValue));
    setState(() {
      _gift = _gift!.copyWith(
        isPurchased: nextValue,
        datePurchased: nextValue ? DateTime.now() : null,
      );
    });
  }

  Future<void> _openEdit() async {
    if (_gift == null) return;
    final updated = await context.push<Gift>(
      AppRoutePaths.giftEdit(_gift!.id),
    );
    if (!mounted) return;
    if (updated != null) {
      context.read<GiftsBloc>().add(UpdateGift(updated));
      setState(() => _gift = updated);
    }
  }

  Future<void> _deleteGift() async {
    if (_gift == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить подарок'),
        content: Text('“${_gift!.title}” будет удалён.'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Отмена')),
          FilledButton(onPressed: () => ctx.pop(true), child: const Text('Удалить')),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    context.read<GiftsBloc>().add(DeleteGift(_gift!.id));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GiftsBloc, GiftsState>(
      builder: (context, state) {
        if (_gift == null && state is GiftsLoaded) {
          _loadGift();
        }

        if (_gift == null) {
          return const Scaffold(
            body: Center(child: Text('Подарок не найден')),
          );
        }

        final statusColor = _gift!.isPurchased ? Colors.green : theme.colorScheme.primary;

        return Scaffold(
          appBar: AppBar(
            title: Text(_gift!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Редактировать',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _openEdit,
              ),
              IconButton(
                tooltip: _gift!.isPurchased ? 'Вернуть в план' : 'Отметить купленным',
                icon: Icon(_gift!.isPurchased ? Icons.undo : Icons.check_circle_outline),
                onPressed: _togglePurchased,
              ),
              IconButton(
                tooltip: 'Удалить',
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteGift,
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
                        child: GiftHeaderImage(imageUrl: _gift!.imageUrl, title: _gift!.title),
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
                                  _gift!.isPurchased ? Icons.check_circle : Icons.pending_actions,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _gift!.isPurchased ? 'Куплено' : 'В планах',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Spacer(),
                                _PriorityStars(
                                  value: _gift!.priority,
                                  onTap: (v) => context
                                      .read<GiftsBloc>()
                                      .add(UpdateGiftPriority(_gift!.id, v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Получатель',
                                value: _gift!.recipient),
                            _InfoRow(
                              icon: Icons.category_outlined,
                              label: 'Категория',
                              value: _gift!.category ?? 'Без категории',
                            ),
                            _InfoRow(
                              icon: Icons.attach_money,
                              label: 'Бюджет',
                              value: formatMoney(_gift!.plannedPrice),
                            ),
                            _InfoRow(
                              icon: Icons.event_available,
                              label: 'Добавлено',
                              value: formatDate(_gift!.dateAdded),
                            ),
                            _InfoRow(
                              icon: Icons.event,
                              label: 'Покупка',
                              value: _gift!.datePurchased == null
                                  ? '-'
                                  : formatDate(_gift!.datePurchased!),
                            ),
                            if (_gift!.note != null && _gift!.note!.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Комментарий', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text(_gift!.note!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_gift!.imageUrl != null && _gift!.imageUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Ссылка на изображение', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(_gift!.imageUrl!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _togglePurchased,
                      icon: Icon(_gift!.isPurchased ? Icons.undo : Icons.check),
                      label: Text(_gift!.isPurchased ? 'Вернуть в план' : 'Отметить купленным'),
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
