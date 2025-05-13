# Web Navigation Implementation Guide

## Ensuring Proper Routing in Web Browsers

### Common Web Navigation Issues

1. **Browser History Management**: Web apps need to integrate with the browser's history API
2. **Deep Linking**: URLs should be able to directly navigate to specific pages
3. **Page Refresh Handling**: Web apps need to handle state restoration after page refresh

### Implementation Steps

#### 1. Setup Web-Compatible Router

If using GoRouter, ensure it's properly configured for web:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id'];
        return ProductDetailScreen(productId: productId!);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    // Add more routes as needed
  ],
  errorBuilder: (context, state) => NotFoundScreen(),
  // Enable URL strategy that removes the hash from URLs
  urlPathStrategy: UrlPathStrategy.path,
);
```

#### 2. Configure URL Strategy for Clean URLs

Add the following code in your main.dart file:

```dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  // Set URL strategy for web
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  
  // Continue with app initialization
  runApp(MyApp());
}
```

#### 3. Implement Web-Safe Navigation Guard

Create a component to handle navigation guards that work on web:

```dart
class WebNavigationGuard extends StatelessWidget {
  final Widget child;
  final bool Function(BuildContext) canNavigate;
  final Widget Function(BuildContext) redirectTo;

  const WebNavigationGuard({
    Key? key,
    required this.child,
    required this.canNavigate,
    required this.redirectTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check navigation permission
    if (canNavigate(context)) {
      return child;
    } else {
      // For web, we want to update the URL too
      if (kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final router = GoRouter.of(context);
          // Navigate to the redirect path
          router.go('/login'); // Replace with your redirect path
        });
      }
      return redirectTo(context);
    }
  }
}
```

#### 4. Handle Deep Linking

Update your web/index.html to support deep linking:

```html
<script>
  // This script handles deep linking for web
  window.addEventListener('load', function() {
    // Initialize the Flutter app first
    _flutter.loader.load();
    
    // Then handle any deep links
    // You might need to adapt this based on your specific URL structure
    const url = new URL(window.location.href);
    if (url.pathname !== '/' && url.pathname !== '') {
      // The path will be passed to your Flutter app via the initial route
      console.log('Deep link detected:', url.pathname);
    }
  });
</script>
```

#### 5. Handle Page Refresh

Implement state persistence to handle page refreshes:

```dart
// In your main app state
void saveStateForRefresh() {
  if (kIsWeb) {
    // Save essential app state to localStorage
    window.localStorage['app_state'] = jsonEncode({
      'currentUser': currentUser?.toJson(),
      'currentPage': currentPage,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      // Add other essential state
    });
  }
}

// Restore state after refresh
void restoreStateAfterRefresh() {
  if (kIsWeb) {
    final savedState = window.localStorage['app_state'];
    if (savedState != null) {
      final stateMap = jsonDecode(savedState);
      // Restore your app state
      if (stateMap['currentUser'] != null) {
        currentUser = User.fromJson(stateMap['currentUser']);
      }
      currentPage = stateMap['currentPage'] ?? 'home';
      // Restore other state
    }
  }
}
```

### Testing Web Navigation

Test the following scenarios:
1. Direct URL access to different routes
2. Browser back/forward buttons
3. Page refresh on various routes
4. Sharing links to specific pages

### Browser Compatibility

Ensure your routing works properly in:
- Chrome
- Firefox
- Safari
- Edge
