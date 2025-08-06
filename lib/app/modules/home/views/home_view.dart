import 'dart:math';

import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nursor_app/app/common/hover_image.dart';
import 'package:nursor_app/app/modules/home/views/customer_button_painter.dart';
import 'package:nursor_app/app/modules/home/views/plan_status.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/service/version_service.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                  CircularMenu(
                    backgroundWidget: Container(width: 100, height: 80, color: Colors.transparent,),
                    radius: 50,
                    alignment: Alignment.topRight, // 调整菜单位置
                    toggleButtonColor: Theme.of(context).colorScheme.primary,
                    toggleButtonSize: 18,
                    toggleButtonIconColor: Colors.white,
                    startingAngleInRadian: pi/3,
                    endingAngleInRadian: pi,
                    items: [
                    CircularMenuItem(
                      icon: Icons.logout,
                      color: Theme.of(context).colorScheme.primaryFixed,
                      iconSize: 18,
                      onTap: () {
                        controller.onLogoutClick();
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.info,
                      iconSize: 18,
                      color: Theme.of(context).colorScheme.primaryFixed,
                      onTap: () {
                        showDialog(context: context, builder: (context) => AlertDialog(
                          title: Text('About Nursor'),
                          content: Text('Current Version: ${VersionService.VersionString}, Latest Version: ${controller.versionService.getVersion().version}'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
                          ],
                        ));
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.settings,
                      iconSize: 18,
                      color: Theme.of(context).colorScheme.primaryFixed,
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.SETTINGS);
                      },
                    ),
                  ],
                  
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 状态栏
                Positioned(
                  right: 20,
                  top: -20,
                  child: Obx(()=> PlanStatus(
                    startTime: DateTime.parse(controller.authService.userInfo.value.startTime),
                    endTime: DateTime.parse(controller.authService.userInfo.value.endTime),
                    width: 150,
                    planCount: controller.authService.userInfo.value.aiAskTotal,
                    planUsed: controller.authService.userInfo.value.aiAskUsed,
                  ))),

                // 按钮
                Positioned(
                  left: screenWidth * 0.5-200,
                  child: Container(
                    width: 400,
                    height: 400,
                    child: GestureDetector(
                      onTap: () async{
                        await controller.onButtonClick();
                      },
                      child: Obx(() => CustomPaint(
                        painter: CustomerButtonPainter(
                          animationValue: controller.animateController.amplitude.value,
                          time: controller.animateController.time.value,
                          randomSeed: controller.animateController.randomSeed.value,
                          sizeRate: controller.animateController.sizeRate.value,  
                          step: controller.animateController.step.value,
                          actionTime: controller.animateController.actionTime.value,
                        ),
                      )),
                    ),
                  ),
                ),

                // Positioned(
                //   left: screenWidth * 0.5-150,
                //   top: 450,
                //   child: Obx(() => Slider(
                //     value: controller.animateController.amplitude.value,
                //     min: 0.0,
                //     max: 150.0,
                //     onChanged: (value) {
                //       controller.animateController.isAnimating.value = true;
                //       controller.animateController.amplitude.value = value;
                //       controller.animateController.updateAnimation();
                //     },
                //     label: 'Amplitude',
                //   )),
                // ),
                // Positioned(
                //   left: screenWidth * 0.5-150,
                //   top: 500,
                //   child: Row(
                //     children: [
                //       ElevatedButton(
                //         onPressed: () {
                //           controller.animateController.startAnimation();
                //         },
                //         child: Text('Start'),
                //       ),
                //       ElevatedButton(
                //         onPressed: () {
                //           controller.animateController.stopAnimation();
                //         },
                //         child: Text('Stop'),
                //       ),

                //       ElevatedButton(
                //         onPressed: () {
                //           controller.animateController.successAnimation();
                //         },
                //         child: Text('success'),
                //       ),

                //       ElevatedButton(
                //         onPressed: () {
                //           controller.animateController.failAnimation();
                //         },
                //         child: Text('fail'),
                //       ),
                //       ElevatedButton(
                //         onPressed: () {
                //           controller.runGate();
                //         },
                //         child: Text('runGate'),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
