import 'package:flutter/material.dart';
import 'package:minimum/i18n/translations.g.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? _message;

  const ConfirmationDialog({
    super.key,
    required this.title,
    String? message,
  }) : _message = message;

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return AlertDialog(
      title: Text(title),
      content: _message != null ? Text(_message) : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(translation.no),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(translation.yes),
        ),
      ],
    );
  }
}
