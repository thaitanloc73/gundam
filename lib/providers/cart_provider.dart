import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, CartItem> get items => _items;
  int get totalItems => _items.values.fold(0, (acc, item) => acc + item.quantity);

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
      // Gọi lên Firebase, vào bảng users, lấy tài liệu của user hiện tại
      final doc = await _firestore.collection('users').doc(_userId).get();
      _items.clear();
      
      if (doc.exists) {
        final data = doc.data()!;
        // Nếu user này đã có trường 'cart' thì lấy dữ liệu về
        if (data.containsKey('cart')) {
          final Map<String, dynamic> cartMap = Map<String, dynamic>.from(data['cart']);
          cartMap.forEach((key, value) {
            _items[key] = CartItem.fromMap(Map<String, dynamic>.from(value));
          });
        }
      }
      notifyListeners(); // Báo cho giao diện cập nhật
    } catch (e) {
      debugPrint("Lỗi tải giỏ hàng: $e");
      _items = {};
      notifyListeners();
    }
  }

  // Hàm đồng bộ giỏ hàng lên Firebase mỗi khi có thay đổi
  Future<void> _syncCart() async {
    if (_userId == null) return;
    try {
      // Chuyển danh sách sản phẩm thành dạng JSON/Map để lưu
      final cartMap = _items.map((key, value) => MapEntry(key, value.toMap()));
      
      // Dùng merge: true để chỉ cập nhật trường 'cart' mà không làm mất các trường khác (như name, email, favorites...)
      await _firestore.collection('users').doc(_userId).set({
        'cart': cartMap
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Lỗi đồng bộ giỏ hàng: $e");
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
    await _syncCart();
    notifyListeners();
  }
}
