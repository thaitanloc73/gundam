import 'order_item.dart';

class Order {
  final String? id;
  final String userId;
  final double totalAmount;
  final String address;
  final String phone;
  final String status;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.address,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'total_amount': totalAmount,
      'address': address,
      'phone': phone,
      'status': status,
      'created_at': createdAt,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, {String? id}) {
    return Order(
      id: id,
      userId: map['user_id'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      address: map['address'] as String,
      phone: map['phone'] as String,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      items: map['items'] != null
          ? (map['items'] as List).map((item) => OrderItem.fromMap(item as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
