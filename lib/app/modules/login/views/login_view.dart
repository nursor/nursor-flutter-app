import 'package:flutter/material.dart';
import 'dart:math' show pi, sin;

import 'package:get/get.dart';
import 'package:nursor_app/app/common/hover_image.dart';
import 'package:nursor_app/app/service/auth_service.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  Widget _buildShakeAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      key: ValueKey(controller.errorCount.value),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            sin(value * 3 * pi) * 10,
            0,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/nursor.png', width: 64, height: 64),
                  
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 150),
                    width: 300,
                    height: 80,
                    child: Column(
                      children: [
                        Obx(() => _buildShakeAnimation(
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: controller.hasError.value ? Colors.red : Colors.grey,
                                width: controller.hasError.value ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                filled: true,
                                border: InputBorder.none,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                              ),
                            ),
                          ),
                        )),
                        Obx(() => controller.hasError.value
                          ? Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink()),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 150,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () {
                        controller.login();
                      },
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

