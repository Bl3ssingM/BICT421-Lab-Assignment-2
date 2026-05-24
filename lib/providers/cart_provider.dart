import 'package:flutter/material.dart';
import '../models/restaurant.dart';

const double _zarRate = 18.5;

/// Manages the shopping cart across the entire application.
///
/// Any widget can:
///   - Read cart state with `context.watch<CartProvider>()`
///   - Mutate cart state with `context.read<CartProvider>().add(...)`
class CartProvider extends ChangeNotifier {
  final Map<Item, int> _items = {};

  // ── Getters ────────────────────────────────────────────────────────────────

  /// An unmodifiable view of the current cart contents.
  Map<Item, int> get items => Map.unmodifiable(_items);

  /// Total number of individual items (sum of quantities).
  int get totalCount =>
      _items.values.fold(0, (sum, qty) => sum + qty);

  /// Total price in USD.
  double get totalPriceUsd =>
      _items.entries.fold(0.0, (sum, e) => sum + e.key.price * e.value);

  /// Total price formatted in South African Rand.
  String get totalPriceZar =>
      'R${(totalPriceUsd * _zarRate).toStringAsFixed(2)}';

  bool get isEmpty => _items.isEmpty;

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Adds [quantity] of [item] to the cart and notifies listeners.
  void add(Item item, int quantity) {
    _items[item] = (_items[item] ?? 0) + quantity;
    notifyListeners();
  }

  /// Removes one unit of [item]. Removes the entry entirely if qty reaches 0.
  void removeOne(Item item) {
    if (!_items.containsKey(item)) return;
    if (_items[item]! <= 1) {
      _items.remove(item);
    } else {
      _items[item] = _items[item]! - 1;
    }
    notifyListeners();
  }

  /// Clears the cart entirely (called after a successful checkout).
  void clear() {
    _items.clear();
    notifyListeners();
  }
}