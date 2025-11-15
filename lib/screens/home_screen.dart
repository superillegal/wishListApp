import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/gift.dart';
import '../navigation/app_routes.dart';
import '../navigation/route_args.dart';
import '../utils/format.dart';
import '../services/image_service.dart';
import '../widgets/budget_bar.dart';
import '../widgets/gift_image.dart';
import '../widgets/statistics_card.dart';
import 'all_gifts_screen.dart';
import 'purchased_gifts_screen.dart';
import 'planned_gifts_screen.dart';

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

  Future<void> _addGift(Gift g) async {
    String? imageUrl = g.imageUrl;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      try {
        imageUrl = await ImageService.instance.nextImageUrl();
      } catch (e) {
        debugPrint('Не удалось получить изображение из пула: $e');
      }
    }
    final withImage = (imageUrl == null) ? g : g.copyWith(imageUrl: imageUrl);
    setState(() => _gifts.insert(0, withImage));
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

  void _openAllScreen() {
    context.push(
      AppRoutePaths.allGifts,
      extra: GiftListRouteArgs(
        title: 'Все подарки',
        gifts: _gifts,
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
    );
  }

  void _openPurchasedScreen() {
    context.push(
      AppRoutePaths.purchasedGifts,
      extra: GiftListRouteArgs(
        title: 'Купленные подарки',
        gifts: _gifts.where((g) => g.isPurchased).toList(),
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
    );
  }

  void _openPlannedScreen() {
    context.push(
      AppRoutePaths.plannedGifts,
      extra: GiftListRouteArgs(
        title: 'Подарки в ожидании',
        gifts: _gifts.where((g) => !g.isPurchased).toList(),
        onOpen: _openDetails,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
    );
  }

  Future<void> _changeBudgetLimit() async {
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
          TextButton(onPressed: () => ctx.pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              ctx.pop(v);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (newLimit != null) setState(() => _budgetLimit = newLimit);
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
      final imageUrl = await ImageService.instance.nextImageUrl();
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

  Future<void> _openAddForm() async {
    final created = await context.push<Gift>(AppRoutePaths.giftForm);
    if (created != null) await _addGift(created);
  }

  Future<void> _openDetails(Gift g) async {
    await context.push(
      AppRoutePaths.giftDetails(g.id),
      extra: GiftDetailRouteArgs(
        gift: g,
        onUpdate: _updateGift,
        onDelete: _deleteGift,
        onTogglePurchased: _togglePurchased,
        onSetPriority: _setPriority,
      ),
    );
  }

  void _openProfile() {
    context.push(AppRoutePaths.profile);
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
        onOpenAll: _openAllScreen,
        onOpenPurchased: _openPurchasedScreen,
        onOpenPlanned: _openPlannedScreen,
        onOpenProfile: _openProfile,
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
        title: const Text('Wishlist Gifts'),
        actions: [
          IconButton(
            tooltip: 'All gifts',
            icon: const Icon(Icons.list_alt),
            onPressed: _openAllScreen,
          ),
          IconButton(
            tooltip: 'Purchased',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _openPurchasedScreen,
          ),
          IconButton(
            tooltip: 'Planned',
            icon: const Icon(Icons.pending_actions),
            onPressed: _openPlannedScreen,
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: _openProfile,
          ),
          IconButton(
            tooltip: 'Budget limit',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: _changeBudgetLimit,
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
            child: Text('Пока нет элементов. Нажми «Добавить».'),
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
      _NavItem('purchased', Icons.check_circle_outline, 'Куплено', onOpenPurchased),
      _NavItem('planned', Icons.pending_actions, 'В ожидании', onOpenPlanned),
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

