import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../models/product.dart';

/// The one global cart. Lives above MaterialApp, so every route sees the same
/// data and rebuilds on notifyListeners().
class CartProvider extends ChangeNotifier {
  final Map<int, int> _items = {};

  /// Total items ever added; the "Fill the bag" coin mission counts this.
  int itemsAdded = 0;

  Map<int, int> get items => Map.unmodifiable(_items);

  bool contains(Product product) => _items.containsKey(product.id);

  int get quantity => _items.values.fold(0, (sum, count) => sum + count);

  double get total => _items.entries.fold(
    0,
    (sum, item) => sum + productById(item.key).price * item.value,
  );

  void add(Product product, {int quantity = 1}) {
    _items[product.id] = (_items[product.id] ?? 0) + quantity;
    itemsAdded += quantity;
    notifyListeners();
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void toggle(Product product) =>
      contains(product) ? remove(product.id) : add(product);

  void changeQuantity(int productId, int difference) {
    final next = (_items[productId] ?? 0) + difference;
    if (next <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = next;
    }
    if (difference > 0) itemsAdded += difference;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
