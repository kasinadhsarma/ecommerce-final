# Firebase Web Authentication Testing

## Prerequisites
- Ensure Firebase web configuration is properly set up in `web/index.html`
- Verify Firebase SDK scripts are loaded correctly
- Check that Firebase initialization is properly handled in `main.dart`

## Testing Steps

### 1. Basic Authentication Flow Testing
```dart
// Code for testing sign-in with email/password
Future<void> testEmailPasswordSignIn() async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "test@example.com", 
      password: "password123"
    );
    print("Sign in successful!");
  } catch (e) {
    print("Sign in failed: $e");
  }
}

// Code for testing sign-up with email/password
Future<void> testEmailPasswordSignUp() async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "newuser@example.com", 
      password: "securepassword123"
    );
    print("Sign up successful!");
  } catch (e) {
    print("Sign up failed: $e");
  }
}
```

### 2. Social Authentication Testing
```dart
// Code for testing Google Sign-In
Future<void> testGoogleSignIn() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    await FirebaseAuth.instance.signInWithCredential(credential);
    print("Google sign in successful!");
  } catch (e) {
    print("Google sign in failed: $e");
  }
}
```

### 3. Persistence Testing
```dart
// Code to check if user session persists after page refresh
void checkPersistence() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      print("User is still signed in after refresh: ${user.uid}");
    } else {
      print("User is signed out after refresh");
    }
  });
}
```

### 4. Common Web-specific Issues and Solutions

1. **CORS Errors**: Ensure your Firebase project has the correct domain listed in the authorized domains list in the Firebase Console.

2. **Missing or Incorrect API Keys**: Verify that the apiKey in your Firebase configuration matches what's in the Firebase Console.

3. **Popup Blockers**: Inform users to allow popups for social authentication methods that use popup windows.

4. **IndexedDB Issues**: Some browsers in private/incognito mode restrict IndexedDB access, which Firebase uses for persistence.

## Testing in Different Browsers

Test Firebase authentication in:
- Chrome
- Firefox
- Safari
- Edge

Verify that authentication flows work correctly in each browser environment.
