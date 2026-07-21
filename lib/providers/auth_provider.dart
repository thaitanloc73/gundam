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

  Future<bool> tryAutoLogin() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return false;
    }

    try {
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
      print("Lỗi tự động đăng nhập: $e");
    }
    return false;
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
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
      }
      
      _isLoading = false;
      notifyListeners();
      return 'Đăng nhập thất bại, không nhận được thông tin từ Firebase.';
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

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Lưu thông tin người dùng vào Firestore
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
        return null; // Trả về null nghĩa là thành công
      }
      
      _isLoading = false;
      notifyListeners();
      return 'Không thể tạo tài khoản trên Firebase.';
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
