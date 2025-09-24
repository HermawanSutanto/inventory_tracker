// lib/providers/auth_provider.dart (VERSI BARU DENGAN FIREBASE)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Dengarkan perubahan status autentikasi secara real-time
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Proses login dengan Firebase
  Future<String?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Sukses, tidak ada pesan error
    } on FirebaseAuthException catch (e) {
      // Tangani error spesifik dari Firebase
      if (e.code == 'user-not-found') {
        return 'Email tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        return 'Password salah.';
      } else if (e.code == 'invalid-credential') {
        return 'Email atau Password salah.';
      }
      return 'Terjadi error: ${e.message}';
    }
  }

  // Proses logout dari Firebase
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
