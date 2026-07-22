import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;

  // Hàm tự động đăng nhập khi mở app (kiểm tra xem phiên đăng nhập trước đó còn hạn không)
  Future<bool> tryAutoLogin() async {
    // Lấy thông tin user hiện tại từ bộ nhớ tạm của Firebase
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return false; // Chưa từng đăng nhập hoặc đã đăng xuất
    }

    try {
      // Tải thêm thông tin cá nhân (tên, role, số điện thoại...) từ bảng 'users'
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          password: '', // Không cần lưu password ở local state
          role: data['role'] ?? 'customer',
          name: data['name'] ?? 'Khách',
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi tự động đăng nhập: $e");
    }
    return false;
  }

  // Hàm đăng nhập bằng Email và Mật khẩu
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Gửi yêu cầu đăng nhập lên Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Không lấy được thông tin User");

      // Tải thông tin chi tiết từ Database
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          password: '', 
          role: data['role'] ?? 'customer',
          name: data['name'] ?? 'Khách',
        );
      } else {
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          password: '', 
          role: 'customer',
          name: 'Khách',
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return null; // Trả về null nghĩa là không có lỗi -> Thành công
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Mật khẩu hoặc tài khoản không chính xác.';
        default:
          return 'Lỗi đăng nhập: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Hàm đăng ký tài khoản mới
  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Tạo tài khoản định danh trên Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Không lấy được thông tin User");

      // 2. Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': name,
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        password: '',
        role: 'customer',
        name: name,
      );
      
      _isLoading = false;
      notifyListeners();
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
        default:
          return 'Lỗi đăng ký: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
