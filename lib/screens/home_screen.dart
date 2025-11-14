import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../utils/format.dart';
import '../services/image_service.dart';
import '../widgets/budget_bar.dart';
import '../widgets/gift_image.dart';
import '../widgets/statistics_card.dart';
import 'all_gifts_screen.dart';
import 'purchased_gifts_screen.dart';
import 'planned_gifts_screen.dart';
import 'gift_form_screen.dart';
import 'gift_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final List<Gift> _gifts = [];
  bool _isGeneratingInitial = false;
  double _budgetLimit = 20000;

  @override
  void initState() {
    super.initState();
    _generateInitialGifts();
  }

  double get _spent =>
      _gifts.where((g) => g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));
  double get _planned =>
      _gifts.where((g) => !g.isPurchased).fold(0.0, (sum, g) => sum + (g.plannedPrice ?? 0));
  int get _purchasedCount => _gifts.where((g) => g.isPurchased).length;
  int get _plannedCount => _gifts.where((g) => !g.isPurchased).length;

  void _addGift(Gift g) {
    setState(() => _gifts.insert(0, g));
    _showSnack('Добавлено: ${g.title}');
  }

  void _updateGift(Gift g) {
    final i = _gifts.indexWhere((e) => e.id == g.id);
    if (i != -1) {
      setState(() => _gifts[i] = g);
      _showSnack('Обновлено: ${g.title}');
    }
  }

  void _deleteGift(String id) {
    final i = _gifts.indexWhere((e) => e.id == id);
    if (i != -1) {
      final removed = _gifts[i];
      setState(() => _gifts.removeAt(i));
      _showSnack('Удалено: ${removed.title}');
    }
  }

  void _togglePurchased(String id) {
    final i = _gifts.indexWhere((e) => e.id == id);
    if (i != -1) {
      final g = _gifts[i];
      final toggled = g.copyWith(
        isPurchased: !g.isPurchased,
        datePurchased: (!g.isPurchased) ? DateTime.now() : null,
      );
      setState(() => _gifts[i] = toggled);
    }
  }

  void _setPriority(String id, int priority) {
    final i = _gifts.indexWhere((e) => e.id == id);
    if (i != -1) {
      setState(() => _gifts[i] = _gifts[i].copyWith(priority: priority));
    }
  }

  Future<void> _generateInitialGifts() async {
    setState(() => _isGeneratingInitial = true);
    final templates = [
      (
        title: 'Новый смартфон',
        recipient: 'Аня',
        plannedPrice: 7500.0,
        priority: 5,
        category: 'Электроника'
      ),
      (
        title: 'Набор для творчества',
        recipient: 'Маша',
        plannedPrice: 4200.0,
        priority: 4,
        category: 'Для дома'
      ),
      (
        title: 'Книга по Flutter',
        recipient: 'Игорь',
        plannedPrice: 2200.0,
        priority: 5,
        category: 'Книги'
      ),
      (
        title: 'Парфюмерный набор',
        recipient: 'Юля',
        plannedPrice: 3100.0,
        priority: 3,
        category: 'Аксессуары'
      ),
      (
        title: 'Игровая консоль',
        recipient: 'Вова',
        plannedPrice: 5600.0,
        priority: 4,
        category: 'Электроника'
      ),
    ];

    final generated = <Gift>[];
    for (final t in templates) {
      final imageUrl = await ImageService.instance.generateImageUrl();
      generated.add(
        Gift.newDraft(
          title: t.title,
          recipient: t.recipient,
          plannedPrice: t.plannedPrice,
          priority: t.priority,
          category: t.category,
          imageUrl: imageUrl,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _gifts
        ..clear()
        ..addAll(generated);
      _isGeneratingInitial = false;
    });
  }

  void _openAddForm() async {
    final created = await Navigator.of(context).push<Gift>(
      MaterialPageRoute(builder: (_) => const GiftFormScreen()),
    );
    if (created != null) _addGift(created);
  }

  void _openDetails(Gift g) async {
    final updatedOrDeleted = await Navigator.of(context).push<_DetailResult>(
      MaterialPageRoute(
        builder: (_) => GiftDetailScreen(
          gift: g,
          onUpdate: _updateGift,
          onDelete: _deleteGift,
          onTogglePurchased: _togglePurchased,
          onSetPriority: _setPriority,
        ),
      ),
    );
    if (updatedOrDeleted == null) return;

  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        gifts: _gifts,
        purchasedCount: _purchasedCount,
        plannedCount: _plannedCount,
        spent: _spent,
        planned: _planned,
        budgetLimit: _budgetLimit,
        onOpenAll: () => setState(() => _tab = 1),
        onOpenPurchased: () => setState(() => _tab = 2),
        onOpenPlanned: () => setState(() => _tab = 3),
        onOpenDetails: _openDetails,
      ),
      AllGiftsScreen(
        gifts: _gifts,
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
      PurchasedGiftsScreen(
        gifts: _gifts.where((g) => g.isPurchased).toList(),
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
      PlannedGiftsScreen(
        gifts: _gifts.where((g) => !g.isPurchased).toList(),
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
    ];

    final body = (_isGeneratingInitial && _gifts.isEmpty)
        ? const Center(child: CircularProgressIndicator())
        : pages[_tab];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist подарков'),
        actions: [
          IconButton(
            tooltip: 'Изменить лимит бюджета',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () async {
              final ctrl = TextEditingController(text: _budgetLimit.toStringAsFixed(0));
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
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                    FilledButton(
                      onPressed: () {
                        final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                        Navigator.pop(ctx, v);
                      },
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
              );
              if (newLimit != null) setState(() => _budgetLimit = newLimit);
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Все идеи'),
          NavigationDestination(icon: Icon(Icons.check_circle_outlined), label: 'Куплено'),
          NavigationDestination(icon: Icon(Icons.pending_actions), label: 'В планах'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddForm,
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            )
          : FloatingActionButton(
              onPressed: _openAddForm,
              child: const Icon(Icons.add),
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
            child: Text('Пока нет элементов. Нажми «Добавить».'),
          ),
      ],
    );
  }
}


class _DetailResult {
  const _DetailResult();
}

