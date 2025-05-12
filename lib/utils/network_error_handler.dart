import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Enum defining different types of network errors
enum NetworkErrorType {
  timeout,
  noInternet,
  serverError,
  forbidden,
  notFound,
  cors, // Specific to web
  unknown,
}

/// A class to handle network errors gracefully across web and mobile platforms
class NetworkErrorHandler {
  /// Attempts to make an HTTP request with proper error handling
  ///
  /// This method wraps http requests with proper timeout and error handling,
  /// returning the response if successful, or throwing a handled NetworkError
  static Future<http.Response> safeHttpRequest(
    Future<http.Response> Function() httpRequest, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Execute the HTTP request with a timeout
      final response = await httpRequest().timeout(timeout);

      // Check the status code and handle common error codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw NetworkError(
          statusCode: response.statusCode,
          message: 'Request failed with status: ${response.statusCode}',
          type: _getErrorTypeFromStatusCode(response.statusCode),
          body: response.body,
        );
      }
    } on TimeoutException {
      throw NetworkError(
        message: 'Request timed out',
        type: NetworkErrorType.timeout,
      );
    } on SocketException {
      throw NetworkError(
        message: 'No internet connection',
        type: NetworkErrorType.noInternet,
      );
    } on HttpException catch (e) {
      // For web, specifically check if this is a CORS error
      if (kIsWeb && e.toString().toLowerCase().contains('cors')) {
        throw NetworkError(
          message:
              'Cross-Origin Request Blocked: The Same Origin Policy prohibits this request',
          type: NetworkErrorType.cors,
        );
      }

      throw NetworkError(
        message: 'HTTP Exception: ${e.toString()}',
        type: NetworkErrorType.unknown,
      );
    } catch (e) {
      // Handle any other errors
      throw NetworkError(
        message: 'Network error: ${e.toString()}',
        type: NetworkErrorType.unknown,
      );
    }
  }

  /// Maps HTTP status codes to NetworkErrorType
  static NetworkErrorType _getErrorTypeFromStatusCode(int statusCode) {
    if (statusCode == 403) {
      return NetworkErrorType.forbidden;
    } else if (statusCode == 404) {
      return NetworkErrorType.notFound;
    } else if (statusCode >= 500) {
      return NetworkErrorType.serverError;
    } else {
      return NetworkErrorType.unknown;
    }
  }

  /// Shows a user-friendly error dialog for network errors
  static void showErrorDialog(BuildContext context, NetworkError error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getTitleForErrorType(error.type)),
          content: Text(_getMessageForError(error)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            if (error.type == NetworkErrorType.noInternet ||
                error.type == NetworkErrorType.timeout)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Here you could add retry logic
                },
                child: const Text('Retry'),
              ),
          ],
        );
      },
    );
  }

  /// Returns a user-friendly title based on error type
  static String _getTitleForErrorType(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.timeout:
        return 'Request Timeout';
      case NetworkErrorType.noInternet:
        return 'No Internet Connection';
      case NetworkErrorType.serverError:
        return 'Server Error';
      case NetworkErrorType.forbidden:
        return 'Access Denied';
      case NetworkErrorType.notFound:
        return 'Not Found';
      case NetworkErrorType.cors:
        return 'Security Error';
      case NetworkErrorType.unknown:
        return 'Error';
    }
  }

  /// Returns a user-friendly message based on error type
  static String _getMessageForError(NetworkError error) {
    // Web-specific messaging
    if (kIsWeb) {
      switch (error.type) {
        case NetworkErrorType.cors:
          return 'This request was blocked due to browser security policies. Please ensure the server allows cross-origin requests.';
        case NetworkErrorType.timeout:
          return 'The server took too long to respond. Please check your internet connection or try again later.';
        case NetworkErrorType.noInternet:
          return 'Please check your internet connection and try again.';
        case NetworkErrorType.serverError:
          return 'We\'re experiencing issues with our server. Please try again later.';
        case NetworkErrorType.forbidden:
          return 'You don\'t have permission to access this resource.';
        case NetworkErrorType.notFound:
          return 'The requested resource was not found. Please check the URL and try again.';
        case NetworkErrorType.unknown:
          return error.message;
      }
    } else {
      // Mobile-specific messaging
      switch (error.type) {
        case NetworkErrorType.timeout:
          return 'The server took too long to respond. Please check your internet connection and try again.';
        case NetworkErrorType.noInternet:
          return 'Please check your internet connection and try again.';
        case NetworkErrorType.serverError:
          return 'We\'re experiencing issues with our server. Please try again later.';
        case NetworkErrorType.forbidden:
          return 'You don\'t have permission to access this resource.';
        case NetworkErrorType.notFound:
          return 'The requested resource was not found.';
        case NetworkErrorType.cors:
          // CORS isn't applicable for mobile, but handle it for completeness
          return error.message;
        case NetworkErrorType.unknown:
          return error.message;
      }
    }
  }
}

/// A custom exception class for network errors
class NetworkError implements Exception {
  final String message;
  final NetworkErrorType type;
  final int? statusCode;
  final String? body;

  NetworkError({
    required this.message,
    required this.type,
    this.statusCode,
    this.body,
  });

  @override
  String toString() {
    return 'NetworkError: $message (Type: $type, Status: $statusCode)';
  }
}
