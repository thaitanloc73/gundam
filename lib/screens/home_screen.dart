import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/gundam_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/gundam_card.dart';
import '../widgets/loading_widget.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GundamProvider>(context, listen: false).fetchGundams();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(surfaceColor, isDark),
          SliverToBoxAdapter(child: _buildBannerCarousel()),
          SliverToBoxAdapter(child: _buildCategoryGrid(isDark, surfaceColor)),
          SliverToBoxAdapter(child: _buildFlashSale(isDark, surfaceColor)),
          SliverToBoxAdapter(child: _buildSectionTitle('Gợi ý hôm nay', isDark)),
          _buildProductGrid(isDark, 2),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trái: Banner, Danh mục, Flash sale (scrollable)
          Expanded(
            flex: 2,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(surfaceColor, isDark),
                SliverToBoxAdapter(child: _buildBannerCarousel()),
                SliverToBoxAdapter(child: _buildCategoryGrid(isDark, surfaceColor)),
                SliverToBoxAdapter(child: _buildFlashSale(isDark, surfaceColor)),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Phải: Grid sản phẩm gợi ý
          Expanded(
            flex: 3,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildSectionTitle('Gợi ý hôm nay', isDark),
                  ),
                ),
                _buildProductGrid(isDark, 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Color surfaceColor, bool isDark) {
    return SliverAppBar(
      backgroundColor: surfaceColor,
      pinned: true,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm mô hình Gundam...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gundamRed),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.gundamRed),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.totalItems == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.gundamRedDark, AppColors.gundamRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'SIÊU SALE 9.9\nGIẢM ĐẾN 50%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark, Color surfaceColor) {
    final categories = [
      {'name': 'SD', 'icon': Icons.child_care},
      {'name': 'HG', 'icon': Icons.star_border},
      {'name': 'RG', 'icon': Icons.star_half},
      {'name': 'MG', 'icon': Icons.star},
      {'name': 'PG', 'icon': Icons.workspace_premium},
      {'name': 'Tools', 'icon': Icons.build},
      {'name': 'Decal', 'icon': Icons.texture},
      {'name': 'Tất cả', 'icon': Icons.category},
    ];

    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'] as IconData, color: AppColors.gundamRed, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                cat['name'] as String,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashSale(bool isDark, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'FLASH SALE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                Text(
                  'Xem tất cả >',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Consumer<GundamProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SizedBox(height: 180, child: LoadingWidget());
              }
              final products = provider.gundams.take(5).toList();
              return SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SizedBox(
                      width: 130,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => const Icon(Icons.image),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      formatPrice(product.price * 0.8), // Giá giảm giả lập
                                      style: const TextStyle(
                                        color: AppColors.gundamRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 80, // Progress giả lập
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          const Center(
                                            child: Text(
                                              'Đã bán 12',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gundamRed,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(bool isDark, int crossAxisCount) {
    return Consumer<GundamProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SliverToBoxAdapter(child: LoadingWidget());
        }

        var products = provider.gundams;
        if (_searchQuery.isNotEmpty) {
          products = products.where((g) => g.name.toLowerCase().contains(_searchQuery)).toList();
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GundamCard(
                  gundam: products[index],
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: products[index].id);
                  },
                );
              },
              childCount: products.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
          ),
        );
      },
    );
  }
}