String formatMoney(double? value, {String currency = '₽'}) {
  if (value == null) return '—';
  // Без пакета intl: простое форматирование
  final s = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  return '$s $currency';
}

String formatDate(DateTime dt) {
  // dd.mm.yyyy
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d.$m.$y';
}
