import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String main = '/main';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
}

class AppColors {
  static const Color gundamRed = Color(0xFFE8002D);
  static const Color gundamRedDark = Color(0xFFB0001F);
  static const Color gundamGold = Color(0xFFFFB800);
  static const Color darkBg = Color(0xFF0D0D0F);
  static const Color darkSurface = Color(0xFF1A1A1E);
  static const Color darkCard = Color(0xFF242428);
  static const Color darkBorder = Color(0xFF2E2E34);
  static const Color lightBg = Color(0xFFF0F0F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F8FC);
}

String formatPrice(double price) {
  final formatted = price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '$formatted₫';
}
