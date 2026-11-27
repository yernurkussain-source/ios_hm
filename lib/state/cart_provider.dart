import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const cartKey = 'cart_items';
  static const productsKey = 'cart_products';

  final SharedPreferences? _prefs;
  final Map<int, int> _items;

  CartProvider([this._prefs]) : _items = _load(_prefs);

  int itemsAdded = 0;
  Map<int, int> get items => Map.unmodifiable(_items);
  bool contains(Product product) => _items.containsKey(product.id);
  int get quantity => _items.values.fold(0, (sum, count) => sum + count);

  double get total => _items.entries.fold(
    0,
    (sum, item) => sum + productById(item.key).price * item.value,
  );

  static Map<int, int> _load(SharedPreferences? prefs) {
    registerProductsJson(prefs?.getString(productsKey));
    final raw = prefs?.getString(cartKey);
    if (raw == null) return {};
    try {
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      final known = allProducts.map((p) => p.id).toSet();
      return {
        for (final e in saved.entries)
          if (known.contains(int.tryParse(e.key)))
            int.parse(e.key): (e.value as num).toInt(),
      };
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  void _changed() {
    notifyListeners();
    _prefs
      ?..setString(
        cartKey,
        jsonEncode(_items.map((id, count) => MapEntry('$id', count))),
      )
      ..setString(productsKey, jsonEncode(extraProductsJson(_items.keys)));
  }

  void add(Product product, {int quantity = 1}) {
    _items[product.id] = (_items[product.id] ?? 0) + quantity;
    itemsAdded += quantity;
    _changed();
  }

  void remove(int productId) {
    _items.remove(productId);
    _changed();
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
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }
}
