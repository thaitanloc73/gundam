import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart' as model;
import '../models/order_item.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  List<model.Order> _orders = [];
  bool _isLoading = false;

  List<model.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    // Admin only, mocked
  }

  Future<void> fetchOrdersByUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersString = prefs.getString('user_orders_$userId') ?? '[]';
      final List<dynamic> ordersJson = json.decode(ordersString);
      _orders = ordersJson.map((data) => model.Order.fromMap(data, id: data['id'])).toList();
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> placeOrder({
    required String userId,
    required String address,
    required String phone,
    required Map<String, CartItem> cartItems,
    required double totalAmount,
  }) async {
    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final orderItemsList = cartItems.values.map((item) => OrderItem(
        gundamId: item.gundamId,
        quantity: item.quantity,
        price: item.price,
        gundamName: item.name,
      )).toList();

      final order = model.Order(
        id: orderId,
        userId: userId,
        totalAmount: totalAmount,
        address: address,
        phone: phone,
        status: 'Pending',
        createdAt: DateTime.now().toIso8601String(),
        items: orderItemsList,
      );

      final prefs = await SharedPreferences.getInstance();
      final ordersString = prefs.getString('user_orders_$userId') ?? '[]';
      final List<dynamic> ordersJson = json.decode(ordersString);
      
      ordersJson.add(order.toMap()..['id'] = orderId);
      await prefs.setString('user_orders_$userId', json.encode(ordersJson));
      
      return null;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<String?> updateOrderStatus(String orderId, String status) async {
    return 'Chức năng chỉ dành cho Admin';
  }

  Future<int> getOrderCount() async => 0;
  Future<double> getTotalRevenue() async => 0;
}
