import 'package:flutter/material.dart';

import '../../data/models/saved_show.dart';

class SavedShowFormResult {
  const SavedShowFormResult({required this.notes, required this.watchStatus});

  final String notes;
  final WatchStatus watchStatus;
}

Future<SavedShowFormResult?> showSavedShowForm(
  BuildContext context, {
  required String title,
  required String initialNotes,
  required WatchStatus initialWatchStatus,
}) {
  return showDialog<SavedShowFormResult>(
    context: context,
    builder: (context) => _SavedShowFormDialog(
      title: title,
      initialNotes: initialNotes,
      initialWatchStatus: initialWatchStatus,
    ),
  );
}

Future<bool> showDeleteConfirmation(
  BuildContext context, {
  required String showName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove from collection?'),
      content: Text(
        '"$showName" and its notes will be deleted from this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _SavedShowFormDialog extends StatefulWidget {
  const _SavedShowFormDialog({
    required this.title,
    required this.initialNotes,
    required this.initialWatchStatus,
  });

  final String title;
  final String initialNotes;
  final WatchStatus initialWatchStatus;

  @override
  State<_SavedShowFormDialog> createState() => _SavedShowFormDialogState();
}

class _SavedShowFormDialogState extends State<_SavedShowFormDialog> {
  late final TextEditingController _notesController;
  late WatchStatus _watchStatus;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
    _watchStatus = widget.initialWatchStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<WatchStatus>(
              initialValue: _watchStatus,
              decoration: const InputDecoration(
                labelText: 'Watch status',
                prefixIcon: Icon(Icons.playlist_add_check_rounded),
              ),
              items: WatchStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _watchStatus = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'What did you think?',
                alignLabelWithHint: true,
              ),
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
          onPressed: () {
            Navigator.of(context).pop(
              SavedShowFormResult(
                notes: _notesController.text.trim(),
                watchStatus: _watchStatus,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
