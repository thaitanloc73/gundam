import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header - User Info
              Container(
                color: surfaceColor,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/logo.png'), // Placeholder
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.isLoggedIn ? 'Người dùng Gundam' : 'Khách',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.isLoggedIn ? 'Thành viên Vàng' : 'Đăng nhập để xem thêm',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!authProvider.isLoggedIn)
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gundamRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Đăng nhập'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Đơn hàng của tôi
              if (authProvider.isLoggedIn)
                Container(
                  color: surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Đơn hàng của tôi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.orders);
                              },
                              child: Text(
                                'Xem lịch sử',
                                style: TextStyle(fontSize: 14, color: Colors.blue.shade600, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _OrderIcon(icon: Icons.wallet, label: 'Chờ thanh toán'),
                          _OrderIcon(icon: Icons.inventory_2_outlined, label: 'Chờ lấy hàng'),
                          _OrderIcon(icon: Icons.local_shipping_outlined, label: 'Đang giao'),
                          _OrderIcon(icon: Icons.star_border, label: 'Đánh giá'),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 10),
              
              // Tiện ích
              Material(
                color: surfaceColor,
                child: Column(
                  children: [
                    if (authProvider.isLoggedIn) ...[
                      ListTile(
                        leading: const Icon(Icons.favorite_border, color: AppColors.gundamRed),
                        title: const Text('Sản phẩm yêu thích'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                      ),
                      const Divider(height: 1, indent: 50),
                    ],

                    Consumer<ThemeProvider>(
                      builder: (context, theme, _) => ListTile(
                        leading: Icon(
                          theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.blue,
                        ),
                        title: const Text('Chế độ giao diện'),
                        trailing: Switch(
                          value: theme.isDarkMode,
                          onChanged: (val) => theme.toggleTheme(),
                          activeTrackColor: AppColors.gundamRed,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 50),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined, color: Colors.grey),
                      title: const Text('Cài đặt'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                    ),
                    if (authProvider.isLoggedIn) ...[
                      const Divider(height: 1, indent: 50),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          authProvider.logout();
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OrderIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng đang phát triển')),
        );
      },
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey[700]),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
