import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> captureThrowable(
  dynamic throwable, {
  String? label,
  StackTrace? stacktrace,
}) {
  debugPrintStack(stackTrace: stacktrace, label: label);
  return Sentry.captureException(
    throwable,
    stackTrace: stacktrace,
    hint: label != null ? Hint.withMap({"label": label}) : null,
  );
}
