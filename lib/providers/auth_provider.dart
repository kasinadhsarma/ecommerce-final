import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Initialize auth state
  Future<void> initAuth() async {
    _setLoading(true);

    try {
      final currentUser = _authService.getCurrentUser();

      if (currentUser != null) {
        _user = currentUser;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        name,
      );

      _user = user;
      _status = AuthStatus.authenticated;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      _user = user;
      _status = AuthStatus.authenticated;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authService.signInWithGoogle();

      _user = user;
      _status = AuthStatus.authenticated;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  void updateUserProfile(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }

  // Enable biometric login
  Future<void> enableBiometricLogin() async {
    if (_user != null) {
      await _authService.enableBiometricLogin(_user!.id);

      _user = _user!.copyWith(isBiometricEnabled: true);
      notifyListeners();
    }
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    if (_user != null) {
      await _authService.disableBiometricLogin(_user!.id);

      _user = _user!.copyWith(isBiometricEnabled: false);
      notifyListeners();
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    return await _authService.authenticateWithBiometrics();
  }

  // Sign in with biometric userId
  Future<bool> signInWithBiometricUserId(String userId) async {
    try {
      final user = await _authService.signInWithBiometricUserId(userId);

      _user = user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Set loading state manually
  void setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
