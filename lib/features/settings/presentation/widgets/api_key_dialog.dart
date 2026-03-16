import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/settings_bloc.dart';

/// Dialog for configuring an API key
class ApiKeyDialog extends StatefulWidget {
  final ApiProvider provider;
  final bool isConfigured;

  const ApiKeyDialog({
    super.key,
    required this.provider,
    required this.isConfigured,
  });

  /// Show the dialog and return true if key was saved
  static Future<bool?> show(
    BuildContext context, {
    required ApiProvider provider,
    required bool isConfigured,
  }) {
    final settingsBloc = context.read<SettingsBloc>();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: settingsBloc,
        child: ApiKeyDialog(
          provider: provider,
          isConfigured: isConfigured,
        ),
      ),
    );
  }

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _keyController = TextEditingController();
  bool _showKey = false;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _keyController.addListener(() {
      setState(() {
        _hasInput = _keyController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        // Show snackbar on validation result
        if (state.validationStatus == ValidationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(state.validationMessage ?? 'API key is valid'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.validationStatus == ValidationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(state.validationMessage ?? 'Invalid API key'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isValidating =
            state.validationStatus == ValidationStatus.validating &&
                state.validatingProvider == widget.provider;

        return AlertDialog(
          title: Text('Configure ${widget.provider.displayName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  widget.provider.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                // Rate limit info
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.provider.rateLimitInfo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // API Key input
                TextField(
                  controller: _keyController,
                  obscureText: !_showKey,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Enter your API key',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showKey ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _showKey = !_showKey),
                      tooltip: _showKey ? 'Hide key' : 'Show key',
                    ),
                  ),
                  enabled: !isValidating,
                ),

                const SizedBox(height: 12),

                // Get API Key link
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Get Free API Key'),
                  onPressed: () => _launchUrl(widget.provider.signupUrl),
                ),

                // Documentation link
                TextButton.icon(
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('View Documentation'),
                  onPressed: () => _launchUrl(widget.provider.docsUrl),
                ),
              ],
            ),
          ),
          actions: [
            // Clear button (only if configured)
            if (widget.isConfigured)
              TextButton(
                onPressed: isValidating ? null : _clearKey,
                child: Text(
                  'Clear',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),

            // Test button
            TextButton(
              onPressed: isValidating || !_hasInput ? null : _testKey,
              child: isValidating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test'),
            ),

            // Save button
            FilledButton(
              onPressed: isValidating || !_hasInput ? null : _saveKey,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _testKey() {
    final key = _keyController.text.trim();
    if (key.isNotEmpty) {
      context.read<SettingsBloc>().add(
            ValidateApiKey(provider: widget.provider, apiKey: key),
          );
    }
  }

  void _saveKey() {
    final key = _keyController.text.trim();
    if (key.isNotEmpty) {
      context.read<SettingsBloc>().add(
            SaveApiKey(provider: widget.provider, apiKey: key),
          );
      Navigator.of(context).pop(true);
    }
  }

  void _clearKey() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear API Key?'),
        content: Text(
          'Are you sure you want to remove the ${widget.provider.displayName} API key? '
          'This will disable features that require this API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (!mounted) return;
      if (confirmed == true) {
        context.read<SettingsBloc>().add(
              ClearApiKey(provider: widget.provider),
            );
        Navigator.of(context).pop(false);
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
