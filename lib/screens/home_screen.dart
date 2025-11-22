import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/gifts/bloc/gifts_bloc.dart';
import '../features/gifts/bloc/gifts_event.dart';
import '../features/gifts/bloc/gifts_state.dart';
import '../models/gift.dart';
import '../navigation/app_routes.dart';
import '../utils/format.dart';
import '../widgets/budget_bar.dart';
import '../widgets/gift_image.dart';
import '../widgets/statistics_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openAddForm(BuildContext context) async {
    final created = await context.push<Gift>(AppRoutePaths.giftForm);
    if (!context.mounted) return;
    if (created != null) {
      context.read<GiftsBloc>().add(AddGift(created));
      _showSnack(context, 'Добавлено: ${created.title}');
    }
  }

  Future<void> _openDetails(BuildContext context, Gift gift) async {
    await context.push(AppRoutePaths.giftDetails(gift.id));
  }

  void _openAllScreen(BuildContext context) => context.push(AppRoutePaths.allGifts);
  void _openPurchasedScreen(BuildContext context) =>
      context.push(AppRoutePaths.purchasedGifts);
  void _openPlannedScreen(BuildContext context) => context.push(AppRoutePaths.plannedGifts);
  void _openProfile(BuildContext context) => context.push(AppRoutePaths.profile);

  Future<void> _changeBudgetLimit(BuildContext context, GiftsLoaded state) async {
    final ctrl = TextEditingController(text: state.budgetLimit.toStringAsFixed(0));
    final newLimit = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Лимит бюджета'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Лимит в ₽'),
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(ctrl.text.replaceAll(',', '.'));
              ctx.pop(value);
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (newLimit != null) {
      context.read<GiftsBloc>().add(ChangeBudgetLimit(newLimit));
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Gifts')
      ),
      body: BlocBuilder<GiftsBloc, GiftsState>(
        builder: (context, state) {
          if (state is GiftsLoading || state is GiftsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GiftsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<GiftsBloc>().add(const LoadGifts()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          if (state is! GiftsLoaded) {
            return const SizedBox.shrink();
          }
          final loaded = state;
          return _HomeTab(
            state: loaded,
            onOpenAll: () => _openAllScreen(context),
            onOpenPurchased: () => _openPurchasedScreen(context),
            onOpenPlanned: () => _openPlannedScreen(context),
            onOpenProfile: () => _openProfile(context),
            onOpenDetails: (g) => _openDetails(context, g),
            onChangeBudget: () => _changeBudgetLimit(context, loaded),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Подарок'),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final GiftsLoaded state;
  final VoidCallback onOpenAll;
  final VoidCallback onOpenPurchased;
  final VoidCallback onOpenPlanned;
  final VoidCallback onOpenProfile;
  final VoidCallback onChangeBudget;
  final void Function(Gift) onOpenDetails;

  const _HomeTab({
    required this.state,
    required this.onOpenAll,
    required this.onOpenPurchased,
    required this.onOpenPlanned,
    required this.onOpenProfile,
    required this.onChangeBudget,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final recent = state.recentGifts;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BudgetBar(limit: state.budgetLimit, spent: state.spent),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'Идей всего',
                value: '${state.totalGifts}',
                icon: Icons.lightbulb_outline,
                onTap: onOpenAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: 'Куплено',
                value: '${state.purchasedCount}',
                icon: Icons.check_circle_outline,
                onTap: onOpenPurchased,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'В планах',
                value: '${state.plannedCount}',
                icon: Icons.pending_actions,
                onTap: onOpenPlanned,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: 'Планируемо',
                value: formatMoney(state.planned),
                icon: Icons.savings_outlined,
                onTap: onChangeBudget,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickNavRow(
          onOpenAll: onOpenAll,
          onOpenPurchased: onOpenPurchased,
          onOpenPlanned: onOpenPlanned,
          onOpenProfile: onOpenProfile,
        ),
        const SizedBox(height: 16),
        Text('Недавно добавленные', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...recent.map((g) => ListTile(
              onTap: () => onOpenDetails(g),
              leading: GiftThumbnail(imageUrl: g.imageUrl, size: 52),
              title: Text(g.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${g.recipient} · ${g.category ?? 'Без категории'}'),
              trailing: Text(formatMoney(g.plannedPrice)),
            )),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Пока ничего нет. Добавьте подарок.'),
          ),
      ],
    );
  }
}

class _QuickNavRow extends StatelessWidget {
  final VoidCallback onOpenAll;
  final VoidCallback onOpenPurchased;
  final VoidCallback onOpenPlanned;
  final VoidCallback onOpenProfile;

  const _QuickNavRow({
    required this.onOpenAll,
    required this.onOpenPurchased,
    required this.onOpenPlanned,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('all', Icons.list_alt, 'Все подарки', onOpenAll),
      _NavItem('purchased', Icons.check_circle_outline, 'Купленные', onOpenPurchased),
      _NavItem('planned', Icons.pending_actions, 'В планах', onOpenPlanned),
      _NavItem('profile', Icons.person_outline, 'Профиль', onOpenProfile),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map(
            (item) => IconButton(
              tooltip: item.tooltip,
              icon: Icon(item.icon),
              onPressed: item.onTap,
            ),
          )
          .toList(),
    );
  }
}

class _NavItem {
  final String id;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavItem(this.id, this.icon, this.tooltip, this.onTap);
}
