import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nursor_app/app/init.dart';
import 'package:nursor_app/app/main_window.dart';
import 'package:nursor_app/app/utils/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'app/routes/app_pages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


void main() async {
  await init();
  await SentryFlutter.init(
      (options) {
        options.dsn = 'https://e15be4bbd136fe5c5c90ae25ae210196@sentry.nursor.org/15';
        options.tracesSampleRate = 0.1;
      },
      appRunner: () async => runApp(
        SentryWidget(
          child: const MyApp(initialRoute: Routes.WELCOME_PAGE),
        ),
      ),
    );
}

