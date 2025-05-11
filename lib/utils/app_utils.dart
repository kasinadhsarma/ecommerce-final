import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Date/time formatting utilities
class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

// Currency formatting
class CurrencyUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}

// Validations
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    return null;
  }

  static String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zip code is required';
    }

    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (!zipRegex.hasMatch(value)) {
      return 'Please enter a valid zip code';
    }

    return null;
  }
}

// Helper function to show snackbar
void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}

// Navigation helper functions
void navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

void navigateAndReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

// App theme and colors
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color accent = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
}

// App text styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onPrimary,
  );
}
