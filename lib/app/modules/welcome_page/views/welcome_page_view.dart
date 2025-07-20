import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/init.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import '../controllers/welcome_page_controller.dart';

class WelcomePageView extends StatefulWidget {
  const WelcomePageView({super.key});

  @override
  State<WelcomePageView> createState() => _WelcomePageViewState();
}

class _WelcomePageViewState extends State<WelcomePageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 监听 isLoading
    final controller = Get.find<WelcomePageController>();
    controller.isLoading.listen((loading) {
      if (loading) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    });

    // 如果一开始就是 loading，启动动画
    if (controller.isLoading.value) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration:  BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33e74c3c),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child:  Center(
              child: Image.asset("assets/images/nursor.png"),
            ),
          ),
        ),
      ),
    );
  }
}
