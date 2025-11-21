import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../models/gift.dart';
import '../navigation/app_routes.dart';
import '../widgets/gift_tile.dart';

class AllGiftsScreen extends StatefulWidget {
  const AllGiftsScreen({super.key});

  @override
  State<AllGiftsScreen> createState() => _AllGiftsScreenState();
}

class _AllGiftsScreenState extends State<AllGiftsScreen> {
  String _query = '';
  String _statusFilter = 'all'; // all / purchased / planned
  String _sort = 'date_desc'; // date_desc / price_asc / price_desc / prio_desc

  @override
  Widget build(BuildContext context) {
    final appState = AppStateInheritedWidget.of(context);
    if (appState == null) {
      return const Center(child: Text('AppState не найден'));
    }

    List<Gift> list = appState.gifts.where((g) {
      final matchQuery = _query.trim().isEmpty ||
          g.title.toLowerCase().contains(_query.toLowerCase()) ||
          g.recipient.toLowerCase().contains(_query.toLowerCase());
      final matchStatus = _statusFilter == 'all'
          ? true
          : (_statusFilter == 'purchased' ? g.isPurchased : !g.isPurchased);
      return matchQuery && matchStatus;
    }).toList();

    switch (_sort) {
      case 'price_asc':
        list.sort((a, b) => (a.plannedPrice ?? 0).compareTo(b.plannedPrice ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.plannedPrice ?? 0).compareTo(a.plannedPrice ?? 0));
        break;
      case 'prio_desc':
        list.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'date_desc':
      default:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Поиск по названию или получателю',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Фильтр',
                icon: const Icon(Icons.filter_alt_outlined),
                onSelected: (v) => setState(() => _statusFilter = v),
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'all', child: Text('Все')),
                  PopupMenuItem(value: 'purchased', child: Text('Купленные')),
                  PopupMenuItem(value: 'planned', child: Text('В планах')),
                ],
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'Сортировка',
                icon: const Icon(Icons.sort),
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'date_desc', child: Text('По дате (новые)')),
                  PopupMenuItem(value: 'price_asc', child: Text('По цене ↑')),
                  PopupMenuItem(value: 'price_desc', child: Text('По цене ↓')),
                  PopupMenuItem(value: 'prio_desc', child: Text('По приоритету')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Подарков не найдено'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final g = list[i];
                    return GiftTile(
                      gift: g,
                      onTap: () => ctx.push(AppRoutePaths.giftDetails(g.id)),
                      onDelete: () => appState.onDeleteGift(g.id),
                      onTogglePurchased: () => appState.onTogglePurchased(g.id),
                      onSetPriority: (p) => appState.onSetPriority(g.id, p),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
