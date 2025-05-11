import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart' as app_models;
import 'biometric_auth_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricAuthService _biometricService = BiometricAuthService();

  // Get current user
  app_models.User? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return app_models.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Sign up with email and password
  Future<app_models.User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      final user = app_models.User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
      );

      return user;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<app_models.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return app_models.User(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName,
        phoneNumber: userCredential.user!.phoneNumber,
        photoUrl: userCredential.user!.photoURL,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<app_models.User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) {
        throw Exception('Google sign in aborted');
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return app_models.User(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName,
        phoneNumber: userCredential.user!.phoneNumber,
        photoUrl: userCredential.user!.photoURL,
      );
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canCheckBiometrics && isDeviceSupported;
  }

  // Enable biometric login
  Future<void> enableBiometricLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$userId', true);
  }

  // Disable biometric login
  Future<void> disableBiometricLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$userId', false);
  }

  // Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled_$userId') ?? false;
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Sign in with biometric user ID
  Future<app_models.User> signInWithBiometricUserId(String userId) async {
    try {
      // Get the user from Firebase (you may need to store additional info in shared prefs)
      final userDoc = await _firebaseAuth.userChanges().firstWhere(
            (user) => user?.uid == userId,
            orElse: () => throw Exception('User not found'),
          );

      if (userDoc == null) {
        throw Exception('User not found');
      }

      return app_models.User(
        id: userDoc.uid,
        email: userDoc.email ?? '',
        name: userDoc.displayName,
        phoneNumber: userDoc.phoneNumber,
        photoUrl: userDoc.photoURL,
      );
    } catch (e) {
      throw Exception('Biometric sign in failed: ${e.toString()}');
    }
  }
}
