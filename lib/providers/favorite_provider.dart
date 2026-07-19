import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gundam.dart';
import 'gundam_provider.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  List<Gundam> _favorites = [];
  String? _userId;

  Set<String> get favoriteIds => _favoriteIds;
  List<Gundam> get favorites => _favorites;

  bool isFavorite(String gundamId) => _favoriteIds.contains(gundamId);

  Future<void> loadFavorites(String userId, GundamProvider gundamProvider) async {
    _userId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favString = prefs.getString('fav_$_userId');
      
      _favoriteIds.clear();
      _favorites.clear();

      if (favString != null) {
        final List<dynamic> favList = json.decode(favString);
        for (var id in favList) {
          _favoriteIds.add(id.toString());
          final gundam = await gundamProvider.getGundamById(id.toString());
          if (gundam != null) {
            _favorites.add(gundam);
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    notifyListeners();
  }

  Future<void> _syncFavorites() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fav_$_userId', json.encode(_favoriteIds.toList()));
    } catch (e) {
      // Ignore
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
