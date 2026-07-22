import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as model;
import '../models/order_item.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  List<model.Order> _orders = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<model.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    // Chức năng này dành cho Admin (hiển thị tất cả đơn hàng của mọi người)
    // Sẽ làm sau
  }

  // Tải danh sách đơn hàng của MỘT người dùng cụ thể từ Firebase
  Future<void> fetchOrdersByUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .get();

      _orders = snapshot.docs.map((doc) {
        return model.Order.fromMap(doc.data(), id: doc.id);
      }).toList();

      // Sắp xếp đơn hàng mới nhất lên đầu
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint("Lỗi khi tải đơn hàng: $e");
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // Tạo một đơn hàng mới, đẩy lên Firebase
  Future<String?> placeOrder({
    required String userId,
    required String address,
    required String phone,
    required Map<String, CartItem> cartItems,
    required double totalAmount,
  }) async {
    try {
      // Đóng gói danh sách sản phẩm trong giỏ
      final orderItemsList = cartItems.values.map((item) => OrderItem(
        gundamId: item.gundamId,
        quantity: item.quantity,
        price: item.price,
        gundamName: item.name,
      )).toList();

      // Lưu thời gian hiện tại
      final createdAt = DateTime.now().toIso8601String();

      final order = model.Order(
        userId: userId,
        totalAmount: totalAmount,
        address: address,
        phone: phone,
        status: 'Pending',
        createdAt: createdAt,
        items: orderItemsList,
      );

      // Lưu lên collection 'orders' (Firestore sẽ tự động tạo một cái ID rác ngẫu nhiên, ví dụ: '7fX2d...')
      final docRef = await _firestore.collection('orders').add(order.toMap());

      // Ngay sau khi đẩy lên mạng thành công, ta gắn cái ID rác đó vào đối tượng order 
      // và nhét thẳng vào đầu mảng (_orders) trên điện thoại luôn.
      // Nhờ vậy Lịch sử mua hàng sẽ hiện ra lập tức mà không cần phải gọi hàm fetchOrdersByUser kéo về lại, giúp app chạy mượt hơn.
      final newOrder = model.Order(
        id: docRef.id,
        userId: userId,
        totalAmount: totalAmount,
        address: address,
        phone: phone,
        status: 'Pending',
        createdAt: createdAt,
        items: orderItemsList,
      );
      
      _orders.insert(0, newOrder);
      notifyListeners();

      return null;
    } catch (e) {
      debugPrint("Lỗi đặt hàng: $e");
      return 'Có lỗi xảy ra khi đặt hàng: $e';
    }
  }

  Future<String?> updateOrderStatus(String orderId, String status) async {
    return 'Chức năng chỉ dành cho Admin';
  }

  Future<int> getOrderCount() async => 0;
  Future<double> getTotalRevenue() async => 0;
}
