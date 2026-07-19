import 'package:flutter/material.dart';
import '../models/gundam.dart';

class GundamProvider extends ChangeNotifier {
  List<Gundam> _gundams = [];
  bool _isLoading = false;

  List<Gundam> get gundams => _gundams;
  bool get isLoading => _isLoading;

  Future<void> fetchGundams() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      _gundams = [
        Gundam(id: '1', name: 'RX-78-2 Gundam (Revive)', grade: 'HG', scale: '1/144', series: 'Mobile Suit Gundam', price: 350000, stock: 10, imageUrl: 'https://i.ebayimg.com/images/g/3rQAAeSwNyhoZPwp/s-l1600.webp'),
        Gundam(id: '2', name: 'Unicorn Gundam', grade: 'RG', scale: '1/144', series: 'Gundam Unicorn', price: 850000, stock: 5, imageUrl: 'https://i.ebayimg.com/images/g/7jIAAeSw3ltoaOef/s-l1600.webp'),
        Gundam(id: '3', name: 'Wing Gundam Zero Custom EW', grade: 'MG', scale: '1/100', series: 'Gundam Wing', price: 1250000, stock: 3, imageUrl: 'https://i.ebayimg.com/images/g/9UcAAeSwp8JqIGRW/s-l960.webp'),
        Gundam(id: '4', name: 'Gundam Aerial', grade: 'HG', scale: '1/144', series: 'Witch from Mercury', price: 450000, stock: 12, imageUrl: 'https://i.ebayimg.com/images/g/K-8AAeSwwatp3ftS/s-l1600.webp'),
        Gundam(id: '5', name: 'SD RX-78-2', grade: 'SD', scale: 'Non-scale', series: 'Mobile Suit Gundam', price: 200000, stock: 20, imageUrl: 'https://i.ebayimg.com/images/g/XXQAAeSweJZqFBiH/s-l1600.webp'),
        Gundam(id: '6', name: 'Strike Freedom', grade: 'PG', scale: '1/60', series: 'Gundam SEED Destiny', price: 5500000, stock: 2, imageUrl: 'https://i.ebayimg.com/images/g/AKMAAOSwGM9m4aPv/s-l1600.webp'),
        Gundam(id: '7', name: 'Sazabi', grade: 'RG', scale: '1/144', series: "Char's Counterattack", price: 1150000, stock: 4, imageUrl: 'https://i.ebayimg.com/images/g/KuYAAeSw6bxouBKL/s-l1600.webp'),
        Gundam(id: '8', name: 'Barbatos Lupus Rex', grade: 'HG', scale: '1/144', series: 'Iron-Blooded Orphans', price: 480000, stock: 8, imageUrl: 'https://i.ebayimg.com/images/g/8LwAAeSw9JZqL8n0/s-l500.webp'),
      ];
    } catch (e) {
      _gundams = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Gundam?> getGundamById(String id) async {
    try {
      return _gundams.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String?> addGundam(Gundam gundam) async {
    return 'Chức năng chỉ dành cho Admin';
  }

  Future<String?> updateGundam(Gundam gundam) async {
    return 'Chức năng chỉ dành cho Admin';
  }

  Future<String?> deleteGundam(String id) async {
    return 'Chức năng chỉ dành cho Admin';
  }
}
