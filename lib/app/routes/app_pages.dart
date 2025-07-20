import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/need_update/bindings/need_update_binding.dart';
import '../modules/need_update/views/need_update_view.dart';
import '../modules/permissiondeny/bindings/permissiondeny_binding.dart';
import '../modules/permissiondeny/views/permissiondeny_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/welcome_page/bindings/welcome_page_binding.dart';
import '../modules/welcome_page/views/welcome_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      fullscreenDialog: false,
      curve: Curves.bounceInOut,
      popGesture: false,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.NEED_UPDATE,
      page: () => const NeedUpdateView(),
      binding: NeedUpdateBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSIONDENY,
      page: () => const PermissiondenyView(),
      binding: PermissiondenyBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME_PAGE,
      page: () => const WelcomePageView(),
      binding: WelcomePageBinding(),
    ),
  ];
}
