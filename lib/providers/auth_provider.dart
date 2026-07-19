import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _currentUser = User(
      id: extractedData['id'],
      email: extractedData['email'],
      password: extractedData['password'] ?? '',
      role: extractedData['role'] ?? 'customer',
      name: extractedData['name'] ?? '',
    );
    notifyListeners();
    return true;
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate network request

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString('usersData') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersString);

      if (users.containsKey(email)) {
        final userData = users[email];
        if (userData['password'] == password) {
          _currentUser = User(
            id: userData['id'],
            email: userData['email'],
            password: userData['password'],
            role: userData['role'] ?? 'customer',
            name: userData['name'] ?? '',
          );
          
          final userDataString = json.encode({
            'id': _currentUser!.id,
            'email': _currentUser!.email,
            'role': _currentUser!.role,
            'name': _currentUser!.name,
          });
          await prefs.setString('userData', userDataString);
          
          _isLoading = false;
          notifyListeners();
          return null;
        } else {
          _isLoading = false;
          notifyListeners();
          return 'Mật khẩu không chính xác.';
        }
      }
      _isLoading = false;
      notifyListeners();
      return 'Không tìm thấy tài khoản với email này.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate network request

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString('usersData') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersString);

      if (users.containsKey(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Email này đã được sử dụng.';
      }

      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': password,
        'name': name,
        'role': 'customer',
      };

      users[email] = newUser;
      await prefs.setString('usersData', json.encode(users));

      _currentUser = User(
        id: newUser['id']!,
        email: newUser['email']!,
        password: newUser['password']!,
        role: newUser['role']!,
        name: newUser['name']!,
      );

      final userDataString = json.encode({
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'role': _currentUser!.role,
        'name': _currentUser!.name,
      });
      await prefs.setString('userData', userDataString);

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Có lỗi xảy ra: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    _currentUser = null;
    notifyListeners();
  }
}
