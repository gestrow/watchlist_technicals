import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A confirmation dialog for deleting a watchlist.
class DeleteConfirmationDialog extends StatelessWidget {
  final String watchlistName;

  const DeleteConfirmationDialog({
    super.key,
    required this.watchlistName,
  });

  /// Shows the dialog and returns true if confirmed, false/null if cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required String watchlistName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        watchlistName: watchlistName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Watchlist'),
      content: Text(
        'Are you sure you want to delete "$watchlistName"?\n\n'
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
