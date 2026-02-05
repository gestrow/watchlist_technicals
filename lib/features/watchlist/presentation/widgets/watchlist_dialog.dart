import 'package:flutter/material.dart';

import '../../domain/entities/watchlist.dart';

/// Result returned from the watchlist dialog.
class WatchlistDialogResult {
  final String name;
  final List<String> symbols;

  const WatchlistDialogResult({
    required this.name,
    required this.symbols,
  });
}

/// Dialog for adding or editing a watchlist.
class WatchlistDialog extends StatefulWidget {
  final Watchlist? watchlist;

  const WatchlistDialog({
    super.key,
    this.watchlist,
  });

  /// Shows the dialog and returns the result if saved, null if cancelled.
  static Future<WatchlistDialogResult?> show(
    BuildContext context, {
    Watchlist? watchlist,
  }) {
    return showDialog<WatchlistDialogResult>(
      context: context,
      builder: (context) => WatchlistDialog(watchlist: watchlist),
    );
  }

  @override
  State<WatchlistDialog> createState() => _WatchlistDialogState();
}

class _WatchlistDialogState extends State<WatchlistDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolsController;

  bool get isEditing => widget.watchlist != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.watchlist?.name ?? '',
    );
    _symbolsController = TextEditingController(
      text: widget.watchlist?.symbols.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolsController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a watchlist name';
    }
    return null;
  }

  String? _validateSymbols(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter at least one symbol';
    }

    final symbols = Watchlist.parseSymbols(value);
    if (symbols.isEmpty) {
      return 'Please enter valid stock symbols (letters only)';
    }

    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final symbols = Watchlist.parseSymbols(_symbolsController.text);

    Navigator.of(context).pop(WatchlistDialogResult(
      name: name,
      symbols: symbols,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Watchlist' : 'Add Watchlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My Watchlist',
              ),
              textCapitalization: TextCapitalization.words,
              validator: _validateName,
              autofocus: !isEditing,
            ),
            const SizedBox(height: 16),

            // Symbols field
            TextFormField(
              controller: _symbolsController,
              decoration: const InputDecoration(
                labelText: 'Symbols',
                hintText: 'AAPL, GOOGL, MSFT',
                helperText: 'Separate symbols with commas or spaces',
                helperMaxLines: 2,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLines: 3,
              minLines: 1,
              validator: _validateSymbols,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
