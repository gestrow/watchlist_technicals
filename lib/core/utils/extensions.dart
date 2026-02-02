import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedString({String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(this);
  }

  String toTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

extension DoubleExtensions on double {
  String toFormattedPrice({int decimalPlaces = 2}) {
    return toStringAsFixed(decimalPlaces);
  }

  String toFormattedPercentage({int decimalPlaces = 2, bool includeSign = true}) {
    final formatted = toStringAsFixed(decimalPlaces);
    if (includeSign && this > 0) {
      return '+$formatted%';
    }
    return '$formatted%';
  }

  String toCompactNumber() {
    if (abs() >= 1e9) {
      return '${(this / 1e9).toStringAsFixed(2)}B';
    } else if (abs() >= 1e6) {
      return '${(this / 1e6).toStringAsFixed(2)}M';
    } else if (abs() >= 1e3) {
      return '${(this / 1e3).toStringAsFixed(2)}K';
    } else {
      return toStringAsFixed(2);
    }
  }
}

extension StringExtensions on String {
  bool isValidSymbol() {
    if (isEmpty) return false;
    // Stock symbols are typically 1-5 uppercase letters
    final regex = RegExp(r'^[A-Z]{1,5}$');
    return regex.hasMatch(this);
  }

  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : null,
      ),
    );
  }
}
