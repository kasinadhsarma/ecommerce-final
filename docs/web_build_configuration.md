# Web Build Configuration Guide

## Optimizing Flutter Web Performance

### 1. Configure Web Renderer

Flutter web supports two rendering strategies:

#### HTML Renderer
- Better performance for simple UIs
- Smaller download size
- Uses a combination of HTML, CSS, Canvas, and SVG

#### CanvasKit Renderer
- Consistent rendering with mobile
- Better performance for complex UIs
- Larger download size due to CanvasKit WebAssembly binary

To specify a renderer, use the following build command:

```bash
# For HTML renderer (better for simple UIs, faster initial load)
flutter build web --web-renderer html

# For CanvasKit renderer (better for complex UIs, consistent rendering)
flutter build web --web-renderer canvaskit

# For auto detection (HTML on mobile, CanvasKit on desktop)
flutter build web --web-renderer auto
```

For our e-commerce app with complex UI elements, CanvasKit is recommended for desktop browsers, while HTML renderer is better for mobile browsers to reduce initial load time.

### 2. Asset Optimization for Web

#### Image Optimization

1. **WebP Format**: Convert PNG/JPEG images to WebP for smaller file sizes

```dart
// Use conditional asset loading
Widget getOptimizedImage(String imagePath) {
  if (kIsWeb) {
    return Image.asset('$imagePath.webp');
  } else {
    return Image.asset('$imagePath.png');
  }
}
```

2. **Responsive Images**: Serve different sizes based on viewport

```dart
Widget responsiveProductImage(String productId, BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  String imagePath;
  
  if (width < 600) {
    imagePath = 'assets/images/products/${productId}_small.webp';
  } else if (width < 1200) {
    imagePath = 'assets/images/products/${productId}_medium.webp';
  } else {
    imagePath = 'assets/images/products/${productId}_large.webp';
  }
  
  return Image.asset(imagePath);
}
```

#### Font Optimization

1. **Subset Fonts**: Only include the characters you need

2. **Use Web Fonts**: For web-specific builds, consider using web fonts

```html
<!-- In web/index.html -->
<head>
  <!-- Add this for web fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
</head>
```

### 3. Service Worker Configuration

Set up a proper service worker for offline support:

1. Update `web/index.html`:

```html
<!-- Add this meta tag for PWA support -->
<meta name="theme-color" content="#0175C2">

<!-- Add this link for PWA icon -->
<link rel="manifest" href="manifest.json">
```

2. Update `web/manifest.json`:

```json
{
  "name": "Ecommerce App",
  "short_name": "Ecommerce",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "A modern e-commerce experience",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

3. Customize the service worker for offline access to key pages:

Create a file `web/custom_service_worker.js`:

```javascript
// Custom service worker for e-commerce app

// Cache names
const CACHE_NAME = 'ecommerce-app-cache-v1';
const STATIC_CACHE = 'ecommerce-static-cache-v1';

// Resources to cache
const STATIC_RESOURCES = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter_service_worker.js',
  '/favicon.png',
  '/manifest.json',
  '/assets/fonts/MaterialIcons-Regular.otf',
  // Add key assets paths here
  '/assets/images/placeholder.png',
  '/assets/icons/placeholder.png'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => {
      return cache.addAll(STATIC_RESOURCES);
    })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== STATIC_CACHE) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      // Cache hit - return response
      if (response) {
        return response;
      }

      // Clone the request
      const fetchRequest = event.request.clone();

      // Make network request and cache the response
      return fetch(fetchRequest).then((response) => {
        // Check if we received a valid response
        if (!response || response.status !== 200 || response.type !== 'basic') {
          return response;
        }

        // Clone the response
        const responseToCache = response.clone();

        // Open cache and store the response
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });

        return response;
      });
    })
  );
});
```

4. Register the custom service worker in `web/index.html`:

```html
<script>
  // Register custom service worker
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('/custom_service_worker.js');
    });
  }
</script>
```

### 4. Lazy Loading and Code Splitting

Implement lazy loading for routes to reduce initial load time:

```dart
// In your router configuration
GoRoute(
  path: '/large-feature',
  builder: (context, state) => FutureBuilder(
    future: Future(() => import('package:myapp/features/large_feature.dart')),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        // Access the lazily loaded module
        final module = snapshot.data;
        return module.LargeFeatureScreen();
      }
      return const LoadingScreen();
    },
  ),
),
```

### 5. Testing and Validation

1. **Lighthouse Audit**: Run Chrome Lighthouse to check performance, accessibility, SEO

2. **WebPageTest**: Test load times and performance across different devices and connection types

3. **PWA Validation**: Use Lighthouse to validate Progressive Web App functionality
