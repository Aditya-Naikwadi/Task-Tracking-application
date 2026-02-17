import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../features/auth/models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth.instance access failed: $e');
      rethrow;
    }
  }

  FirebaseFirestore get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirebaseFirestore.instance access failed: $e');
      rethrow;
    }
  }

  // Auth State Stream
  Stream<User?> get user => _auth.authStateChanges();

  // Sign Up with Profile
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await createUserProfile(
          UserModel(
            uid: credential.user!.uid,
            email: email,
            fullName: fullName,
            role: role,
            createdAt: DateTime.now(),
          ),
        );
      }
      return credential;
    } catch (e) {
      debugPrint('Sign Up Error: $e');
      rethrow;
    }
  }

  // Create/Update User Profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update User Profile Data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Login
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current User
  User? get currentUser => _auth.currentUser;
}
