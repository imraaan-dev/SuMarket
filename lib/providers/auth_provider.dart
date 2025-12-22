import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = true;
  String? _error;

  StreamSubscription<User?>? _authSub;

  AuthProvider() {
    // Listen to login/logout changes
    _authSub = _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = _friendlyGeneralError(e);
      _isLoading = false;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Req: Don't auto-login. Force user to login manually.
      await _auth.signOut();
      _user = null; 
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e);
    } catch (e) {
      _error = _friendlyGeneralError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {

    _setLoading(true);
    _error = null;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = credential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {

      _error = _friendlyAuthError(e);
    } catch (e) {

      _error = _friendlyGeneralError(e);
    } finally {

      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;

    try {
      await _auth.signOut();
      // _user will be updated by authStateChanges listener
    } catch (e) {
      _error = _friendlyGeneralError(e);
    } finally {
      // ✅ Always stop loading so UI never gets stuck
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak (try 6+ characters).';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error. Please try again.';
    }
  }

  String _friendlyGeneralError(Object e) {
    final message = e.toString().toLowerCase();

    if (message.contains('network')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }

    return 'Something went wrong. Please try again later.';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
