import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/data/action_res.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:flutter/services.dart';

class LoginController extends GetxController {

  final emailController = TextEditingController();
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final errorCount = 0.obs;
  final isInstalling = false.obs;
  final installResult = 'Please install the certificate to your system'.obs;
  final installButtonText = 'Install'.obs;
  final isLoading = false.obs;

  final AuthService authService = Get.find();

  static const platform = MethodChannel('com.nursor.cursor_path');

  Future<bool> checkNursorCertificate() async {
    try {
      final bool result = await platform.invokeMethod('checkNursorCert');
      return result;
    } on PlatformException catch (e) {
      // 发生异常时，按需处理
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    authService.isUserAvaliable().then((value) {
      if (value) {
        Get.offAllNamed(Routes.HOME);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    if (!Platform.isMacOS) {
      return;
    }
    checkNursorCertificate().then((value) {
      if (!value) {
        Get.dialog(
          AlertDialog(
            title: const Text('Certificate not valid'),
            content: Text(installResult.value),
            actions: [
              TextButton(
                onPressed: () {
                  installCertificate().then((value) {
                    if (value) {
                      Get.back();
                    }else{
                      installResult.value = "Install certificate failed";
                      installButtonText.value = "Retry";
                    }
                  });
                },
                child: Text(installButtonText.value),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    errorCount.value++;
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  void login() async {
    try {
      clearError();
      isLoading.value = true;
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 旋转动画
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(seconds: 1),
                      curve: Curves.linear,
                      onEnd: () {},
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 2 * pi,
                          child: child,
                        );
                      },
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 24),
                    // 淡入动画
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        "Loading...",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 900),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        "We are verifying your account...",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      ActionRes actionRes = await authService.login(emailController.text);
      if (actionRes.status) {
        if (await authService.isUserAvaliable()) {
          await authService.saveUserInfoToDB();
          await authService.setUserToCursor();
          Get.offAllNamed(Routes.HOME);
        } else {
          setError("Plan expired");
        }
      } else {
        setError(actionRes.message);
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      isLoading.value = false;
      Get.back();
    }
  }

    Future<bool> installCertificate() async {
    final result = await Process.run(
      '/bin/bash',
      ['/Library/Application Support/Nursor/trust_ca_once.sh'],
    );

    print('stdout: ${result.stdout}');
    print('stderr: ${result.stderr}');

    if (result.stderr.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

}
