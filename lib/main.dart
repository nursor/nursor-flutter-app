import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nursor_app/app/init.dart';
import 'package:nursor_app/app/main_window.dart';
import 'app/routes/app_pages.dart';


void main() async {
  await init();
  runApp(const MyApp(initialRoute: Routes.WELCOME_PAGE));
}

