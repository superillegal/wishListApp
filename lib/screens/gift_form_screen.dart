import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftFormScreen extends StatefulWidget {
  final Gift? initial;

  const GiftFormScreen({super.key, this.initial});

  @override
  State<GiftFormScreen> createState() => _GiftFormScreenState();
}

class _GiftFormScreenState extends State<GiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _recipient;
  late final TextEditingController _price;
  String? _category;
  late int _priority;
  late final TextEditingController _note;

  final _categories = const [
    'Без категории',
    'Электроника',
    'Одежда',
    'Аксессуары',
    'Книги',
    'Игрушки',
    'Для дома',
    'Спорт',
    'Другое',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    _title = TextEditingController(text: g?.title ?? '');
    _recipient = TextEditingController(text: g?.recipient ?? '');
    _price = TextEditingController(
        text: g?.plannedPrice == null ? '' : g!.plannedPrice!.toString());
    _category = g?.category ?? 'Без категории';
    _priority = g?.priority ?? 3;
    _note = TextEditingController(text: g?.note ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _recipient.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = _price.text.trim().isEmpty
        ? null
        : double.tryParse(_price.text.replaceAll(',', '.'));
    if (_price.text.trim().isNotEmpty && price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Цена должна быть числом')),
      );
      return;
    }

    if (widget.initial == null) {
      final created = Gift.newDraft(
        title: _title.text.trim(),
        recipient: _recipient.text.trim(),
        plannedPrice: price,
        priority: _priority,
        category: (_category == 'Без категории') ? null : _category,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      Navigator.pop(context, created);
    } else {
      final updated = widget.initial!.copyWith(
        title: _title.text.trim(),
        recipient: _recipient.text.trim(),
        plannedPrice: price,
        priority: _priority,
        category: (_category == 'Без категории') ? null : _category,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать идею' : 'Новая идея'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Название подарка *',
                hintText: 'Напр. наушники, книга, сертификат...',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipient,
              decoration: const InputDecoration(
                labelText: 'Получатель *',
                hintText: 'Кому предназначен подарок',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category ?? 'Без категории',
              decoration: const InputDecoration(labelText: 'Категория'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Цена / бюджет (₽)',
                hintText: 'например 2500',
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Приоритет'),
              child: Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final filled = n <= _priority;
                  return IconButton(
                    onPressed: () => setState(() => _priority = n),
                    icon: Icon(filled ? Icons.star : Icons.star_border),
                    tooltip: '$n',
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Заметка',
                hintText: 'Размер, цвет, ссылка, идеи и т.п.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEdit ? 'Сохранить' : 'Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
