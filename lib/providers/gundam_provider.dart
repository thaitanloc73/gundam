import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gundam.dart';

class GundamProvider extends ChangeNotifier {
  List<Gundam> _gundams = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Gundam> get gundams => _gundams;
  bool get isLoading => _isLoading;

  Future<void> fetchGundams() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore.collection('gundams').get();
      
      // Luôn lấy dữ liệu từ Firebase gán cho biến _gundams
      _gundams = snapshot.docs.map((doc) {
        return Gundam.fromMap(doc.data(), id: doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Lỗi khi tải dữ liệu từ Firebase: $e");
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
