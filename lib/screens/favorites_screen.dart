import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/gundam_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0D0D0F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              color: AppColors.gundamRed,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Yêu thích',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0D0D0F),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, theme, _) => Icon(
                theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: isDark ? Colors.white : const Color(0xFF0D0D0F),
              ),
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, _) {
          final favorites = favProvider.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: isDark ? const Color(0xFF444450) : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm yêu thích',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy nhấn vào biểu tượng ❤ trên sản phẩm\nđể thêm vào danh sách yêu thích',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF888890) : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false),
                    icon: const Icon(Icons.storefront, size: 18),
                    label: const Text('Khám phá sản phẩm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gundamRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return GundamCard(
                gundam: favorites[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: favorites[index].id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
