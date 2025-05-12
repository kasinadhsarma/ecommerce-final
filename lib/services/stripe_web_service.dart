import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:js/js_util.dart' as js_util;
import '../utils/js_interop_utils.dart' as js_interop
    if (dart.library.io) '../utils/no_op_js_interop.dart' as js_interop;
import '../utils/web_compatibility_helper.dart';

class StripeWebService {
  static bool _isInitialized = false;

  static void initStripeWeb() {
    if (kIsWeb && !_isInitialized) {
      try {
        // Load Stripe.js
        debugPrint('Initializing Stripe Web');

        // In a real implementation, would load Stripe.js dynamically if needed
        // and initialize with your publishable key
        _isInitialized = true;
      } catch (e) {
        debugPrint('Error initializing Stripe Web: $e');
      }
    }
  }

  static Future<void> redirectToCheckout({required String sessionId}) async {
    if (kIsWeb) {
      try {
        debugPrint(
            'Redirecting to Stripe checkout with session ID: $sessionId');

        // Using our JS interop utilities to call Stripe.js
        // This is a simplified example. In a real implementation,
        // you would use Stripe.js's redirectToCheckout method
        final window = getProperty(js_util.globalThis, 'window');

        if (getProperty(window, 'Stripe') != null) {
          final stripe =
              callJsMethod(window, 'Stripe', ['YOUR_PUBLISHABLE_KEY']);

          final checkoutOptions = convertDartToJs({
            'sessionId': sessionId,
          });

          final checkoutPromise =
              callJsMethod(stripe, 'redirectToCheckout', [checkoutOptions]);

          // Handle the result
          await handleThenable(checkoutPromise);
        } else {
          // Fallback to direct URL navigation if Stripe.js is not available
          WebCompatibilityHelper.navigateToUrl(
              'https://checkout.stripe.com/pay/$sessionId');
        }
      } catch (e) {
        debugPrint('Error during Stripe checkout: $e');
        // In a real implementation, you'd handle this error and show a user-friendly message
      }
    }
  }

  static Future<Map<String, dynamic>> createPaymentMethod({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    if (kIsWeb) {
      try {
        debugPrint('Creating payment method with Stripe.js');

        // This is a simplified example
        final window = getProperty(js_util.globalThis, 'window');

        if (getProperty(window, 'Stripe') != null) {
          final stripe =
              callJsMethod(window, 'Stripe', ['YOUR_PUBLISHABLE_KEY']);

          final cardDetails = convertDartToJs({
            'card': {
              'number': cardNumber,
              'exp_month': expMonth,
              'exp_year': expYear,
              'cvc': cvc,
            }
          });

          final createPaymentMethodPromise = callJsMethod(
              stripe, 'createPaymentMethod', ['card', cardDetails]);

          // Handle the result
          final result = await handleThenable(createPaymentMethodPromise);
          return convertJsToDart(result);
        } else {
          return {'error': 'Stripe.js not available'};
        }
      } catch (e) {
        debugPrint('Error creating payment method: $e');
        return {'error': e.toString()};
      }
    } else {
      // For mobile, this would use the Stripe SDK
      return {'error': 'Not implemented for mobile yet'};
    }
  }
}
