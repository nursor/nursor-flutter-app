import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/need_update_controller.dart';

class NeedUpdateView extends GetView<NeedUpdateController> {
  const NeedUpdateView({super.key});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    
    return Scaffold(
      body: Column(
        children: [
          Container(height: 150,),
          Image(image: AssetImage('assets/images/upgrade.png'), width: 100, height: 100,),
          Container(
            width: screenWidth,
            height: 100,
            child: Center(child: Text('Need Update', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.6)),),),
          ),
          Container(
            width: screenWidth,
            height: 20,
            child: Center(child: Text('Please update to the latest version', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),),),
          ),
          Container(
            width: screenWidth,
            height: 20,
            child: Center(child: Text('Current Version: ${controller.getCurrentVersion()}, Latest Version: ${controller.getLatestVersion()}', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),),),
          )
          
        ],
      ),
    );
  }
}
