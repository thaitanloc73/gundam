class OrderItem {
  final String gundamId;
  final int quantity;
  final double price;
  final String? gundamName;

  OrderItem({
    required this.gundamId,
    required this.quantity,
    required this.price,
    this.gundamName,
  });

  Map<String, dynamic> toMap() {
    return {
      'gundam_id': gundamId,
      'quantity': quantity,
      'price': price,
      'gundamName': gundamName,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      gundamId: map['gundam_id'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      gundamName: map['gundamName'] as String?,
    );
  }
}
