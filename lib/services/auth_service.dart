import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Add this new method for password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Ошибка сброса пароля: $e');
    }
  }
}
