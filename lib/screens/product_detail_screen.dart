import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gundam.dart';
import '../providers/gundam_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gundamId = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder<Gundam?>(
      future: Provider.of<GundamProvider>(context, listen: false).getGundamById(gundamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingWidget());
        }

        final gundam = snapshot.data;
        if (gundam == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: const Center(child: Text('Không tìm thấy sản phẩm')),
          );
        }

        return Scaffold(
          body: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _buildLandscapeLayout(context, gundam);
              }
              return _buildPortraitLayout(context, gundam);
            },
          ),
          bottomNavigationBar: _buildBottomBar(context, gundam),
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, Gundam gundam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          backgroundColor: surfaceColor,
          leading: IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.black45,
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.black45,
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: gundam.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Icon(Icons.image),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: surfaceColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPrice(gundam.price),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gundamRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  gundam.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const Text(' 4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Text('|'),
                    const SizedBox(width: 10),
                    Text('Đã bán ${100 - gundam.stock}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Container(
            color: surfaceColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gundam Official', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Online 5 phút trước', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng đang phát triển')),
                    );
                  },
                  child: const Text('Xem Shop', style: TextStyle(color: AppColors.gundamRed)),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Container(
            color: surfaceColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Sản phẩm chất lượng cao từ Bandai, độ chi tiết hoàn hảo. Khớp linh hoạt có thể tạo nhiều tư thế đẹp mắt.', style: TextStyle(height: 1.5)),
                const SizedBox(height: 10),
                Text('Dòng: ${gundam.series}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Cấp độ: ${gundam.grade}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Tỉ lệ: ${gundam.scale}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, Gundam gundam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return Row(
      children: [
        // Ảnh bên trái
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: gundam.imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
              ),
              Positioned(
                top: 30,
                left: 10,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Chi tiết bên phải
        Expanded(
          flex: 1,
          child: Container(
            color: surfaceColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatPrice(gundam.price),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gundamRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gundam.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('Sản phẩm chất lượng cao từ Bandai, độ chi tiết hoàn hảo. Khớp linh hoạt có thể tạo nhiều tư thế đẹp mắt.', style: TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Gundam gundam) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, color: Colors.grey.shade600, size: 20),
                  Text('Chat', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Consumer<FavoriteProvider>(
              builder: (context, favProvider, _) {
                final isFav = gundam.id != null ? favProvider.isFavorite(gundam.id!) : false;
                return InkWell(
                  onTap: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn) {
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    if (gundam.id != null) {
                      favProvider.toggleFavorite(gundam.id!, context.read<GundamProvider>());
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.gundamRed : Colors.grey.shade600,
                        size: 20,
                      ),
                      Text('Thích', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _addToCart(context, gundam),
              child: Container(
                color: Colors.orange,
                child: const Center(
                  child: Text(
                    'Thêm vào giỏ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                _addToCart(context, gundam);
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              child: Container(
                color: AppColors.gundamRed,
                child: const Center(
                  child: Text(
                    'Mua ngay',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, Gundam gundam) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    if (gundam.id != null) {
      Provider.of<CartProvider>(context, listen: false).addItem(gundam.id!, gundam.name, gundam.price, gundam.imageUrl);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), duration: Duration(seconds: 1)),
    );
  }
}