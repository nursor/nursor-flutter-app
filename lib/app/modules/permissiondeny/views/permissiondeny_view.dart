import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/permissiondeny_controller.dart';

class PermissiondenyView extends GetView<PermissiondenyController> {
  const PermissiondenyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFf8f9fa),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 动画图标
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                                                  child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFe74c3c).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 60,
                              color: Color(0xFFe74c3c),
                            ),
                          ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // 标题
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                                                      child: const Text(
                              '权限不足',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFe74c3c),
                              ),
                            ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // 描述文字
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                                                      child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFe74c3c).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFe74c3c).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '亲，请以管理员权限，重新打开这个app',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFe74c3c),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  
                  
                  const SizedBox(height: 20),
                  
                  // 提示信息
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                                                      child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFe74c3c).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFe74c3c),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '请右键点击应用图标，选择"以管理员身份运行"',
                                    style: TextStyle(
                                      color: Color(0xFFe74c3c),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
