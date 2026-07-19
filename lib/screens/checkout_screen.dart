import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/gundam_provider.dart';
import '../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final gundamProvider = Provider.of<GundamProvider>(context, listen: false);

    final selectedIds = ModalRoute.of(context)!.settings.arguments as List<String>? ?? cart.items.keys.toList();
    final checkoutItems = Map.fromEntries(cart.items.entries.where((e) => selectedIds.contains(e.key)));
    final totalAmount = checkoutItems.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    if (checkoutItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có sản phẩm nào để thanh toán!')),
      );
      return;
    }

    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await orderProvider.placeOrder(
      userId: auth.currentUser!.id!,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      cartItems: checkoutItems,
      totalAmount: totalAmount,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.gundamRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      setState(() => _isLoading = false);
    } else {
      for (var id in selectedIds) {
        cart.removeItem(id);
      }
      await gundamProvider.fetchGundams();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Đặt hàng thành công!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = Provider.of<CartProvider>(context);
    final selectedIds = ModalRoute.of(context)!.settings.arguments as List<String>? ?? cart.items.keys.toList();
    final checkoutItems = Map.fromEntries(cart.items.entries.where((e) => selectedIds.contains(e.key)));
    final totalAmount = checkoutItems.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ nhận hàng',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập địa chỉ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Số điện thoại chỉ được chứa số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tóm tắt đơn hàng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...checkoutItems.values.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} x${item.quantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888890) : Colors.grey.shade600),
                            ),
                          ),
                          Text(
                            formatPrice(item.price * item.quantity),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0D0D0F),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          formatPrice(totalAmount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gundamRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gundamRed))
                    : ElevatedButton(
                        onPressed: _placeOrder,
                        child: const Text('XÁC NHẬN ĐẶT HÀNG',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}