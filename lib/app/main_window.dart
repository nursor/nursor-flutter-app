import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/utils/theme.dart';
import 'package:window_manager/window_manager.dart';


class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    print('Window listener added');
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<bool> onWindowClose() async {
    print("拦截窗口关闭事件，执行隐藏");
    await windowManager.hide();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Nursor",
      initialRoute: widget.initialRoute,
      getPages: AppPages.routes,
      theme: AppTheme.light,
    );
  }
}
