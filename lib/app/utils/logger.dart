import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



void info(String message) {
  Sentry.captureMessage(
    message,
    level: SentryLevel.info,
  );
}

void error(String message) {
  Sentry.captureException(
    SentryEvent(
      message: SentryMessage(message),
      level: SentryLevel.error,
    ),
  );
}

