import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the app with 4 main sections.
class AppNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      animationDuration: const Duration(milliseconds: 300),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Watchlists',
        ),
        NavigationDestination(
          icon: Icon(Icons.candlestick_chart_outlined),
          selectedIcon: Icon(Icons.candlestick_chart),
          label: 'Technicals',
        ),
        NavigationDestination(
          icon: Icon(Icons.sentiment_satisfied_outlined),
          selectedIcon: Icon(Icons.sentiment_satisfied),
          label: 'Sentiment',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    // Prevent redundant navigation to current page
    if (index == currentIndex) return;

    // Haptic feedback on navigation
    HapticFeedback.lightImpact();

    switch (index) {
      case 0:
        context.go('/watchlists');
      case 1:
        context.go('/technicals');
      case 2:
        context.go('/sentiment');
      case 3:
        context.go('/settings');
    }
  }
}

/// Shell widget that wraps pages with the bottom navigation bar.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavigationBar(currentIndex: currentIndex),
    );
  }
}
