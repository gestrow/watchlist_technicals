import 'package:flutter/material.dart';

import '../../domain/entities/api_provider.dart';

/// A tile showing API provider configuration status
class ApiKeyTile extends StatelessWidget {
  final ApiProvider provider;
  final bool configured;
  final VoidCallback onConfigure;

  const ApiKeyTile({
    super.key,
    required this.provider,
    required this.configured,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildProviderIcon(theme),
        title: Text(
          provider.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              provider.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(theme),
          ],
        ),
        trailing: TextButton(
          onPressed: onConfigure,
          child: Text(configured ? 'Edit' : 'Configure'),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildProviderIcon(ThemeData theme) {
    IconData icon;
    Color color;

    switch (provider) {
      case ApiProvider.finnhub:
        icon = Icons.analytics_outlined;
        color = Colors.blue;
      case ApiProvider.marketaux:
        icon = Icons.newspaper_outlined;
        color = Colors.purple;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    if (configured) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              'Configured',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            'Not Set',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
