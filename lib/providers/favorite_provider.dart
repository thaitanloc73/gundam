import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gundam.dart';
import 'gundam_provider.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  final List<Gundam> _favorites = [];
  String? _userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> get favoriteIds => _favoriteIds;
  List<Gundam> get favorites => _favorites;

  bool isFavorite(String gundamId) => _favoriteIds.contains(gundamId);

  Future<void> loadFavorites(String userId, GundamProvider gundamProvider) async {
    _userId = userId;
    try {
      // Lấy document của user từ Firebase
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      _favoriteIds.clear();
      _favorites.clear();

      if (doc.exists) {
        final data = doc.data()!;
        // Kiểm tra xem đã có danh sách yêu thích chưa
        if (data.containsKey('favorites')) {
          final List<dynamic> favList = data['favorites'];
          for (var id in favList) {
            _favoriteIds.add(id.toString());
            // Từ ID yêu thích, đối chiếu qua GundamProvider để lấy ra sản phẩm thật
            final gundam = await gundamProvider.getGundamById(id.toString());
            if (gundam != null) {
              _favorites.add(gundam);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải mục yêu thích: $e");
    }
    notifyListeners();
  }

  // Cập nhật lại mảng yêu thích lên Firebase mỗi khi có biến động (thêm/bớt)
  Future<void> _syncFavorites() async {
    if (_userId == null) return;
    try {
      // Dùng SetOptions(merge: true) để không ghi đè mất giỏ hàng (cart) hay các trường khác
      await _firestore.collection('users').doc(_userId).set({
        'favorites': _favoriteIds.toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Lỗi đồng bộ mục yêu thích: $e");
    }
  }

  Future<void> toggleFavorite(String gundamId, GundamProvider gundamProvider) async {
    if (_userId == null) return;

    try {
      if (_favoriteIds.contains(gundamId)) {
        _favoriteIds.remove(gundamId);
        _favorites.removeWhere((g) => g.id == gundamId);
      } else {
        _favoriteIds.add(gundamId);
        final gundam = await gundamProvider.getGundamById(gundamId);
        if (gundam != null) {
          _favorites.insert(0, gundam);
        }
      }
      await _syncFavorites();
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  void clear() {
    _userId = null;
    _favoriteIds.clear();
    _favorites.clear();
    notifyListeners();
  }
}
