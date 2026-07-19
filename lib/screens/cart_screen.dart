import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Map lưu trạng thái chọn của từng sản phẩm trong giỏ hàng. Mặc định là chọn hết.
  final Map<String, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    // Khởi tạo tất cả item đều được chọn (theo style Shopee)
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (var item in cart.items.values) {
      _selectedItems[item.gundamId] = true;
    }
  }

  void _toggleSelectAll(bool? value) {
    if (value == null) return;
    setState(() {
      final cart = Provider.of<CartProvider>(context, listen: false);
      for (var item in cart.items.values) {
        _selectedItems[item.gundamId] = value;
      }
    });
  }

  bool _isAllSelected() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) return false;
    for (var item in cart.items.values) {
      if (_selectedItems[item.gundamId] != true) return false;
    }
    return true;
  }

  void _checkout(BuildContext context) {
    if (_countSelectedItems() == 0) return;
    final selectedIds = _selectedItems.entries.where((e) => e.value).map((e) => e.key).toList();
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: selectedIds);
  }

  double _calculateTotalSelected() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    double total = 0;
    for (var item in cart.items.values) {
      if (_selectedItems[item.gundamId] == true) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  int _countSelectedItems() {
    return _selectedItems.values.where((v) => v).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          TextButton(
            onPressed: () {
              // Action Xoá các item đã chọn
            },
            child: const Text('Sửa', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildLandscapeLayout(context);
          }
          return _buildPortraitLayout(context);
        },
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildCartList(context)),
        _buildBottomCheckoutBar(context),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildCartList(context),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tóm tắt đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tạm tính (${_countSelectedItems()} sp):'),
                    Text(
                      formatPrice(_calculateTotalSelected()),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gundamRed),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _countSelectedItems() > 0 ? () => _checkout(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gundamRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Mua Hàng (${_countSelectedItems()})', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Giỏ hàng trống'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gundamRed, foregroundColor: Colors.white),
              child: const Text('Mua sắm ngay'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items.values.toList()[index];
        final isSelected = _selectedItems[item.gundamId] ?? true;

        return Container(
          margin: const EdgeInsets.only(top: 8),
          color: surfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                activeColor: AppColors.gundamRed,
                onChanged: (val) {
                  setState(() {
                    _selectedItems[item.gundamId] = val ?? false;
                  });
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Icon(Icons.image),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      'Phân loại: Mặc định',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatPrice(item.price),
                          style: const TextStyle(color: AppColors.gundamRed, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => cart.decreaseQty(item.gundamId),
                                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade300)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Text('${item.quantity}'),
                              ),
                              InkWell(
                                onTap: () => cart.addItem(item.gundamId, item.name, item.price, item.imageUrl),
                                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Checkbox(
                value: _isAllSelected(),
                activeColor: AppColors.gundamRed,
                onChanged: _toggleSelectAll,
              ),
              const Text('Tất cả'),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('Tổng thanh toán: '),
                  Text(
                    formatPrice(_calculateTotalSelected()),
                    style: const TextStyle(color: AppColors.gundamRed, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _countSelectedItems() > 0 ? () => _checkout(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: _countSelectedItems() > 0 ? AppColors.gundamRed : Colors.grey,
              child: Text(
                'Mua Hàng (${_countSelectedItems()})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}