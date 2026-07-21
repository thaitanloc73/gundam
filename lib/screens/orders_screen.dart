import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Hàm này chạy ngay khi màn hình vừa được mở lên
    Future.microtask(() {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Nếu đã đăng nhập, lập tức chọt qua OrderProvider để tải toàn bộ đơn hàng từ Firebase về
      if (auth.currentUser != null) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrdersByUser(auth.currentUser!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Lịch sử mua hàng'),
        backgroundColor: surfaceColor,
        elevation: 1,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: LoadingWidget());
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có đơn hàng nào.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Bắt đầu vẽ danh sách các đơn hàng (ListView)
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              
              // Chuyển đổi định dạng ngày giờ cho dễ nhìn (từ ISO 8601 sang Ngày/Tháng/Năm)
              final date = DateTime.tryParse(order.createdAt);
              final dateStr = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()) : order.createdAt;

              // Vẽ một thẻ (Card) tương ứng với 1 đơn hàng
              return Card(
                color: surfaceColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cắt 8 ký tự đầu tiên của ID Firebase để làm Mã đơn hàng cho ngắn
                          Text(
                            'Mã: ${order.id?.substring(0, 8).toUpperCase() ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Cái hộp nhỏ bên phải hiển thị trạng thái đơn hàng (Đang giao, Đã hủy...)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Ngày đặt: $dateStr', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      const Divider(),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.quantity}x ${item.gundamName}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text(formatPrice(item.price)),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            formatPrice(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gundamRed,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending': return 'Chờ xử lý';
      case 'Processing': return 'Đang xử lý';
      case 'Shipped': return 'Đang giao';
      case 'Delivered': return 'Đã giao';
      case 'Cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.purple;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
