import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
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
    final appState = AppStateInheritedWidget.read(context);
    if (created != null && appState != null) {
      await appState.onAddGift(created);
      if (!context.mounted) return;
      _showSnack(context, 'Добавлено: ${created.title}');
    }
  }

  Future<void> _openDetails(BuildContext context, Gift gift) async {
    await context.push(AppRoutePaths.giftDetails(gift.id));
  }

  void _openAllScreen(BuildContext context) {
    context.push(AppRoutePaths.allGifts);
  }

  void _openPurchasedScreen(BuildContext context) {
    context.push(AppRoutePaths.purchasedGifts);
  }

  void _openPlannedScreen(BuildContext context) {
    context.push(AppRoutePaths.plannedGifts);
  }

  void _openProfile(BuildContext context) {
    context.push(AppRoutePaths.profile);
  }

  Future<void> _changeBudgetLimit(
    BuildContext context,
    AppStateInheritedWidget appState,
  ) async {
    final ctrl = TextEditingController(text: appState.budgetLimit.toStringAsFixed(0));
    final newLimit = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Лимит бюджета'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Сумма в ₽',
          ),
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(ctrl.text.replaceAll(',', '.'));
              ctx.pop(value);
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
    if (newLimit != null) appState.onChangeBudgetLimit(newLimit);
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateInheritedWidget.of(context);

    if (appState == null) {
      return const Scaffold(
        body: Center(child: Text('Ошибка: AppState не найден')),
      );
    }

    final body = (appState.isGeneratingInitial && appState.gifts.isEmpty)
        ? const Center(child: CircularProgressIndicator())
        : _HomeTab(
            gifts: appState.gifts,
            purchasedCount: appState.purchasedCount,
            plannedCount: appState.plannedCount,
            spent: appState.spent,
            planned: appState.planned,
            budgetLimit: appState.budgetLimit,
            onOpenAll: () => _openAllScreen(context),
            onOpenPurchased: () => _openPurchasedScreen(context),
            onOpenPlanned: () => _openPlannedScreen(context),
            onOpenProfile: () => _openProfile(context),
            onOpenDetails: (g) => _openDetails(context, g),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Gifts'),
        actions: [
          IconButton(
            tooltip: 'All gifts',
            icon: const Icon(Icons.list_alt),
            onPressed: () => _openAllScreen(context),
          ),
          IconButton(
            tooltip: 'Purchased',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _openPurchasedScreen(context),
          ),
          IconButton(
            tooltip: 'Planned',
            icon: const Icon(Icons.pending_actions),
            onPressed: () => _openPlannedScreen(context),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            tooltip: 'Budget limit',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => _changeBudgetLimit(context, appState),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Gift> gifts;
  final int purchasedCount;
  final int plannedCount;
  final double spent;
  final double planned;
  final double budgetLimit;
  final VoidCallback onOpenAll;
  final VoidCallback onOpenPurchased;
  final VoidCallback onOpenPlanned;
  final VoidCallback onOpenProfile;
  final void Function(Gift) onOpenDetails;

  const _HomeTab({
    required this.gifts,
    required this.purchasedCount,
    required this.plannedCount,
    required this.spent,
    required this.planned,
    required this.budgetLimit,
    required this.onOpenAll,
    required this.onOpenPurchased,
    required this.onOpenPlanned,
    required this.onOpenProfile,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final lastAdded = [...gifts]..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    final recent = lastAdded.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BudgetBar(limit: budgetLimit, spent: spent),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'Всего идей',
                value: '${gifts.length}',
                icon: Icons.lightbulb_outline,
                onTap: onOpenAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: 'Куплено',
                value: '$purchasedCount',
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
                value: '$plannedCount',
                icon: Icons.pending_actions,
                onTap: onOpenPlanned,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: 'Запланировано',
                value: formatMoney(planned),
                icon: Icons.savings_outlined,
                onTap: onOpenAll,
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
              subtitle: Text('${g.recipient} • ${g.category ?? 'Без категории'}'),
              trailing: Text(formatMoney(g.plannedPrice)),
            )),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Пока нет идей. Добавьте подарок.'),
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
