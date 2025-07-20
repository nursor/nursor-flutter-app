import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';


class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('设置'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black,),
        ),
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                child: Text('Cursor安装路径'),
              ),
              Container(
                width: 400,
                height: 50,
                child: TextField(
                controller: controller.cursorPathController,
                decoration: InputDecoration(
                  hintText: '请输入Cursor安装路径',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ),
              Obx(() => controller.hasError.value
                          ? Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink()),
              Container(
                width: 200,
                height: 40,
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    controller.handleCursorPathChange(controller.cursorPathController.text);
                  },
                  child: Text('保存'),
                ),  
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  if (Platform.isMacOS) {
                  return ElevatedButton(
                    onPressed: () async{
                      await controller.installCertificate();
                    },
                    child: Text('安装证书'),
                  );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
