import 'package:flutter/material.dart';

/// Persistent banner shown when offline.
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[800],
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You\'re offline. Some features may be unavailable.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows offline banner at the top when offline.
class OfflineAwareWidget extends StatelessWidget {
  final bool isOffline;
  final Widget child;
  final VoidCallback? onRetry;

  const OfflineAwareWidget({
    super.key,
    required this.isOffline,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOffline)
          OfflineBanner(onRetry: onRetry),
        Expanded(child: child),
      ],
    );
  }
}
