import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userData;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.user.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userData = await _authService.getUserProfile(user.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.login(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addXP(int amount) async {
    if (_userData == null || _user == null) return;
    
    int newXP = _userData!.xp + amount;
    int currentLevel = _userData!.level;
    
    // Simple level up logic: level up every 500 XP
    int newLevel = (newXP / 500).floor() + 1;
    
    await _authService.updateUserData(_user!.uid, {
      'xp': newXP,
      'level': newLevel,
    });
    
    // Update local state
    _userData = _userData!.copyWith(xp: newXP, level: newLevel);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
