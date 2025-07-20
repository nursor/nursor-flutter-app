import 'dart:math';
import 'dart:async';

import 'package:get/get.dart';

enum AnimateType {
  starting,
  startingFromFailed,
  stopping,
  running,
  runningFromFailed,
  failed,
  failedAfterRetry,
  unbegin,
}

enum AnimateInnerStepType{
  breathToSmall,
  breathToBig,
}

class AnimateInnerStep{
  final RxString text = "Go".obs;
  final RxDouble sizeRate = 1.0.obs;
  final RxDouble actionTime = 0.0.obs;
  final RxDouble time = 0.0.obs;
  final RxDouble randomSeed = 0.0.obs;
  final RxDouble amplitude = 0.0.obs;
  final RxString breathStep = "small".obs;
}


class AnimateController extends GetxController {
  final RxBool isAnimating = false.obs;
  final Rx<AnimateType> step = AnimateType.unbegin.obs;
  final RxDouble amplitude = 0.0.obs;
  final RxDouble time = 0.0.obs;
  final RxDouble randomSeed = 0.0.obs;
  final RxDouble sizeRate = 1.0.obs;
  final RxDouble actionTime = 0.0.obs;
  Timer? _animationTimer;
  AnimateInnerStep animateInnerStep = AnimateInnerStep();
  final Rx<AnimateInnerStepType> breathStep = AnimateInnerStepType.breathToSmall.obs;
  final RxBool firstBreath = true.obs;


  void startAnimation() {
    step.value = AnimateType.starting;
    isAnimating.value = true;
    amplitude.value = 150.0;
    time.value = 0.0;
    actionTime.value = 0.0;
    randomSeed.value = 0.0;

    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (isAnimating.value) {
        updateAnimation();
      } else {
        timer.cancel();
      }
    });
  }


  void stopAnimation(){
    actionTime.value = 0.0;
    step.value = AnimateType.stopping;
    Timer(const Duration(milliseconds: 2000), () async {
      isAnimating.value = false;
      _animationTimer?.cancel();
      step.value = AnimateType.unbegin;
    });
  }

  void successAnimation() {
    step.value = AnimateType.running;
  }


  void failAnimation() {
    step.value = AnimateType.failed;
  }

  void failedAfterRetryAnimation() {
    step.value = AnimateType.failedAfterRetry;
  }

  void runningFromFailedAnimation() {
    step.value = AnimateType.runningFromFailed;
    actionTime.value = 0.0;
  }

  void startingFromFailedAnimation() {
    step.value = AnimateType.startingFromFailed;
    actionTime.value = 0.0;
  }

  int getAnimateTimeToFinish(){
    var leftTime = 0;
    if (breathStep.value == AnimateInnerStepType.breathToSmall){
      leftTime = ((2-actionTime.value) * 1000).toInt();
    }else{
      leftTime = ((1-actionTime.value) * 1000).toInt();
    }
    print("current actionTime: ${actionTime.value}, sizeRate: ${sizeRate.value}, leftTime: $leftTime , breathStep: ${breathStep.value == AnimateInnerStepType.breathToSmall ? 'toSmall' : 'toBig'}");
    return leftTime;
  }

  void updateAnimation() {
    if(step.value != AnimateType.starting){
      firstBreath.value = true;
      breathStep.value = AnimateInnerStepType.breathToSmall;
    }
    
    switch (step.value) {
      case AnimateType.starting:
        time.value += 0.01;
        // 第一阶段呼吸，先变小到0.8
        if(firstBreath.value){
          if (actionTime.value < 1 && breathStep.value == AnimateInnerStepType.breathToSmall) {
            sizeRate.value = 1 - 0.2 * actionTime.value;
            actionTime.value += 0.01;
          }else{
            firstBreath.value = false;
            breathStep.value = AnimateInnerStepType.breathToBig;
          }
          break;
        }
        // 第二阶段呼吸，呼吸效果，先变大到0.9，再变小到0.8
        if (actionTime.value > 0 && breathStep.value == AnimateInnerStepType.breathToBig) {
          sizeRate.value = 0.8 + 0.1 * (1-actionTime.value);
          actionTime.value -= 0.01;
        }else if (actionTime.value < 1 && breathStep.value == AnimateInnerStepType.breathToSmall) {
          sizeRate.value = 0.9 - 0.1 * actionTime.value;
          actionTime.value += 0.01;
        }else{
          breathStep.value = breathStep.value == AnimateInnerStepType.breathToSmall ? AnimateInnerStepType.breathToBig : AnimateInnerStepType.breathToSmall;
        }
        break;
      case AnimateType.stopping:
        if (actionTime.value < 1) {
          actionTime.value += 0.01;
        }
        time.value += 0.01;
        randomSeed.value = Random().nextDouble();
        break;
      case AnimateType.running:
        if (actionTime.value < 1) {
          sizeRate.value = sizeRate.value < 1 ? sizeRate.value + 0.2 * 0.01 : 1;
          actionTime.value += 0.01;
        }
        time.value += 0.01;
        randomSeed.value = Random().nextDouble();
        break;
      case AnimateType.failed:
        if (actionTime.value < 1) {
          actionTime.value += 0.01;
        }
        time.value += 0.01;;
        break;
      case AnimateType.runningFromFailed:
        if (actionTime.value < 1) {
          actionTime.value += 0.01;
          sizeRate.value = 0.8 + 0.2 * actionTime.value;
        }
        time.value += 0.01;
        break;
      case AnimateType.startingFromFailed:
        actionTime.value += 0.02;
        time.value += 0.01;
        break;
      case AnimateType.failedAfterRetry:
        actionTime.value = 1.0;
        time.value += 0.01;
        break;
      case AnimateType.unbegin:
        break;
    }
  }

  @override
  void onClose() {
    _animationTimer?.cancel();
    super.onClose();
  }
}