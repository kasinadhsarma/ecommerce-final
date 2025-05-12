# E-Commerce Application Documentation

## Overview

This is a full-featured e-commerce application built with Flutter that supports both Android and web platforms. The application integrates various features including user authentication, product browsing, shopping cart management, checkout process, order history, and loyalty rewards.

## Project Structure

### Android Directory

The Android directory contains all Android-specific configurations and resources.

- **build.gradle.kts**: Android build configuration written in Kotlin DSL
  - Uses Gradle plugins for Android, Firebase, and Kotlin
  - Configures the application with unique ID `com.example.myapp`
  - Enables Java 11 compatibility
  - Integrates Google services for Firebase

- **google-services.json**: Firebase configuration file for the Android application
  - Contains Firebase project details including API keys and client IDs
  - Required for Firebase services like authentication and messaging

### Web Directory

The web directory contains configuration files and resources for web deployment.

- **index.html**: Main HTML entry point for the web application
  - Contains meta tags for SEO and mobile web optimization
  - Includes references to web-specific JavaScript files
  - Sets up initial loading screen and application configuration

- **flutter.js**: JavaScript file that initializes the Flutter application in the browser

- **manifest.json**: Web application manifest file
  - Defines web app behavior when installed on a device
  - Specifies icons, theme colors, and application name

- **icons/**: Directory containing various icon sizes for web application
  - Includes standard and maskable icons (for PWA support)
  - Available in sizes 192px and 512px

### Lib Directory

The lib directory contains the main Dart code for the application.

#### Main Application Files

- **main.dart**: Entry point of the application
  - Sets up providers for state management
  - Initializes Firebase for both web and mobile platforms
  - Configures platform-specific settings
  - Implements conditional initialization for web and Android

- **firebase_options.dart**: Firebase configuration options for the Flutter app

#### Models

The models directory contains data model classes that define the structure of the application data.

- **product_model.dart**: Defines the Product class with properties like:
  - ID, title, price, description, category, image, and rating
  - Includes methods for JSON serialization/deserialization

- **user_model.dart**: User data model with properties for authentication and profile

- **cart_model.dart**: Shopping cart model with methods for managing cart items

- **order_model.dart**: Order data model for tracking purchase history

- **loyalty_model.dart**: Loyalty points and rewards program data model

#### Providers

The providers directory contains state management classes using the Provider pattern.

- **auth_provider.dart**: Manages user authentication state
  - Handles sign-in, sign-up, and sign-out operations
  - Maintains current user information

- **cart_provider.dart**: Manages shopping cart state
  - Add, update, and remove items from the cart
  - Calculate totals and handle quantity changes

- **product_provider.dart**: Manages product catalog state
  - Fetches and filters products
  - Handles product categorization and search

- **order_provider.dart**: Manages order history and creation
  - Process new orders
  - Track order status

- **loyalty_provider.dart**: Manages loyalty rewards program
  - Track user points
  - Handle reward redemption

#### Screens

The screens directory contains UI screens organized by feature:

- **splash_screen.dart**: Initial loading screen with brand logo

- **auth/**: Authentication screens
  - **login_screen.dart**: User login form
  - **register_screen.dart**: New user registration
  - **forgot_password_screen.dart**: Password recovery

- **product/**: Product-related screens
  - **category_products_screen.dart**: Products filtered by category
  - **product_details_screen.dart**: Detailed view of a single product
  - **search_screen.dart**: Product search interface

- **cart/**: Shopping cart screens
  - **cart_screen.dart**: Cart items and management
  - **checkout_screen.dart**: Payment and shipping information
  - **order_success_screen.dart**: Order confirmation

- **profile/**: User profile screens
  - **profile_screen.dart**: User information display
  - **edit_profile_screen.dart**: Update user profile
  - **order_history_screen.dart**: List of past orders
  - **order_details_screen.dart**: Detailed view of a specific order
  - **loyalty_rewards_screen.dart**: Loyalty points and available rewards
  - **store_details_screen.dart**: Physical store information

#### Services

The services directory contains classes that handle external API interactions:

- **api_service.dart**: Handles HTTP requests to backend APIs
  - Product catalog fetching
  - Order submission

- **auth_service.dart**: Implements authentication operations
  - Firebase authentication methods
  - Token management

- **biometric_auth_service.dart**: Handles biometric authentication (fingerprint, face ID)

- **notification_service.dart**: Manages push notifications
  - Firebase Cloud Messaging integration
  - Local notifications

- **stripe_web_service.dart**: Handles payment processing with Stripe
  - Web-specific payment implementation

#### Utils

The utils directory contains utility functions and helper classes:

- **app_utils.dart**: General utility functions used throughout the app

- **firebase_config.dart**: Firebase configuration utilities

- **js_interop_utils.dart**: JavaScript interoperability for web platform

- **web_compatibility_helper.dart**: Helpers for cross-platform compatibility

#### Widgets

The widgets directory contains reusable UI components:

- **common_widgets.dart**: Shared UI components used across multiple screens
  - Buttons, cards, input fields, etc.

## Key Dependencies

- **Provider & flutter_bloc**: State management solutions
- **Firebase packages**: Authentication, core functionality, and messaging
- **flutter_stripe**: Payment processing
- **cached_network_image**: Efficient image loading and caching
- **js**: JavaScript interoperability for web
- **flutter_local_notifications**: Local notification management
- **UI components**: flutter_svg, carousel_slider, flutter_rating_bar

## Platform-Specific Features

### Android

- Native Firebase integration
- Biometric authentication
- Device orientation control
- Local notifications

### Web

- Stripe web payment integration
- JavaScript interoperability
- Responsive design for various screen sizes
- Progressive Web App (PWA) capabilities

## Getting Started

1. Clone the repository
2. Install Flutter (version 3.0.0 or higher)
3. Run `flutter pub get` to install dependencies
4. Configure Firebase:
   - Add your own Firebase configuration values in firebase_options.dart
   - Update google-services.json for Android
5. Run the application with `flutter run`

## Testing

The application includes widget tests in the test directory:
- **widget_test.dart**: Basic widget testing for the application
