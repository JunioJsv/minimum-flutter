import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? _message;
  final String? _confirm;
  final String? _decline;

  const ConfirmationDialog({
    super.key,
    required this.title,
    String? message,
    String? confirm,
    String? decline,
  })  : _confirm = confirm,
        _decline = decline,
        _message = message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: _message != null ? Text(_message) : null,
      actions: [
        if (_decline != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(_decline),
          ),
        if (_confirm != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(_confirm),
          ),
      ],
    );
  }
}
