import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Error boundary widget that catches and displays errors gracefully.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails error, VoidCallback onRetry)?
      errorBuilder;
  final void Function(FlutterErrorDetails error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      return _DefaultErrorWidget(
        error: _error!,
        onRetry: _retry,
      );
    }

    return widget.child;
  }
}

/// Default error display widget.
class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState.error(
        message: 'An unexpected error occurred. Please try again.',
        onRetry: onRetry,
      ),
    );
  }
}

/// Global error handler setup.
class GlobalErrorHandler {
  static void init({void Function(Object error, StackTrace stack)? onError}) {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      onError?.call(details.exception, details.stack ?? StackTrace.current);
    };
  }
}

/// Widget to display network error with retry.
class NetworkErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Unable to connect. Please check your connection.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
