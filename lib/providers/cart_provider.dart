import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String gundamId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.gundamId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'gundamId': gundamId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    gundamId: map['gundamId'] ?? '',
    name: map['name'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    imageUrl: map['imageUrl'] ?? '',
    quantity: map['quantity'] ?? 1,
  );
}

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> _items = {};
  String? _userId;

  Map<String, CartItem> get items => _items;
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  Future<void> loadCart(String userId) async {
    _userId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart_$_userId');
      _items.clear();
      if (cartString != null) {
        final Map<String, dynamic> cartMap = json.decode(cartString);
        cartMap.forEach((key, value) {
          _items[key] = CartItem.fromMap(value);
        });
      }
      notifyListeners();
    } catch (e) {
      _items = {};
    }
  }

  Future<void> _syncCart() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartMap = _items.map((key, value) => MapEntry(key, value.toMap()));
      await prefs.setString('cart_$_userId', json.encode(cartMap));
    } catch (e) {
      // Ignored
    }
  }

  void addItem(String gundamId, String name, double price, String imageUrl) {
    if (_items.containsKey(gundamId)) {
      _items[gundamId]!.quantity++;
    } else {
      _items[gundamId] = CartItem(
        gundamId: gundamId,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );
    }
    _syncCart();
    notifyListeners();
  }

  void decreaseQty(String gundamId) {
    if (!_items.containsKey(gundamId)) return;
    if (_items[gundamId]!.quantity > 1) {
      _items[gundamId]!.quantity--;
    } else {
      _items.remove(gundamId);
    }
    _syncCart();
    notifyListeners();
  }

  void removeItem(String gundamId) {
    _items.remove(gundamId);
    _syncCart();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    _syncCart();
    notifyListeners();
  }
}