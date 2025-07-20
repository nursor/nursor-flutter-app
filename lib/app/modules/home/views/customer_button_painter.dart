import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nursor_app/app/service/animate_service.dart';

class CustomerButtonPainter extends CustomPainter {
  final double animationValue; // 动画进度 (0.0 到 1.0)
  final double time; // 当前时间（秒）
  final AnimateType step;
  final double randomSeed; // 随机种子
  final double sizeRate;
  final double actionTime;

  CustomerButtonPainter({
    required this.animationValue,
    required this.time,
    required this.step,
    required this.randomSeed,
    required this.sizeRate,
    required this.actionTime,
  });

  void drawRunning(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    // 创建渐变
    final gradient = RadialGradient(
      colors: [
        Colors.red.withOpacity(1 - 0.2 * min(max(0, actionTime),1)),
        Colors.red.withOpacity(1 - 0.4 * min(max(0, actionTime),1)),
        Colors.red.withOpacity(1 - 0.6 * min(max(0, actionTime),1)),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    final path = Path();
    bool firstPoint = true;
    double firstX = 0.0;
    double firstY = 0.0;

    // 复合波动函数
    for (double theta = 0; theta <= 2 * pi; theta += pi / 360) {
      // 基础波动
      final baseWave = sin(3 * theta + time * 2) * 10;
      
      // 次级波动
      final secondaryWave = cos(5 * theta - time * 1.5) * 5;
      
      // 阻尼波动
      final dampingWave =exp(-0.5 * (theta - pi).abs()) * sin(4 * theta + time) * 8;
      
      // 组合所有波动
      final radius = baseRadius * sizeRate + (baseWave + 
                    secondaryWave + 
                    dampingWave) * actionTime;

      final x = centerX + radius * cos(theta);
      final y = centerY + radius * sin(theta);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
          path.lineTo(x, y);
      }
    }
    
    path.close();

    // 绘制主路径
    canvas.drawPath(path, paint);

    // 绘制文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Running',
        style: TextStyle(
          color: Colors.white.withOpacity(min(max(0, actionTime),1)),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void drawRunningFromFailed(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    // 创建渐变
    final gradient = RadialGradient(
      colors: [
        Color.lerp(Colors.grey, Colors.red, max(0, min(1, actionTime)))!.withOpacity(0.8),
        Color.lerp(Colors.grey, Colors.red, max(0, min(1, actionTime)))!.withOpacity(0.6),
        Color.lerp(Colors.grey, Colors.red, max(0, min(1, actionTime)))!.withOpacity(0.4),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    final path = Path();
    bool firstPoint = true;
    // 复合波动函数
    for (double theta = 0; theta <= 2 * pi; theta += pi / 360) {
      // 基础波动
      final baseWave = sin(3 * theta + time * 2) * 10;
      
      // 次级波动
      final secondaryWave = cos(5 * theta - time * 1.5) * 5;
      
      // 阻尼波动
      final dampingWave = exp(-0.5 * (theta - pi).abs()) * sin(4 * theta + time) * 8;
      
      // 组合所有波动
      final radius = baseRadius * sizeRate + (baseWave + 
                    secondaryWave + 
                    dampingWave) * actionTime;

      final x = centerX + radius * cos(theta);
      final y = centerY + radius * sin(theta);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();

    // 绘制主路径
    canvas.drawPath(path, paint);

    // 绘制文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Running',
        style: TextStyle(
          color: Colors.white.withOpacity(min(max(0, actionTime),1)),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void drawStopping(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    // 创建渐变
    final gradient = RadialGradient(
      colors: [
        Colors.red.withOpacity(min(0.8 + 0.2 * actionTime, 1)),
        Colors.red.withOpacity(min(0.6 + 0.4 * actionTime, 1)),
        Colors.red.withOpacity(min(0.4 + 0.6 * actionTime, 1)),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    final path = Path();
    bool firstPoint = true;
    double firstX = 0.0;
    double firstY = 0.0;

    // 复合波动函数
    for (double theta = 0; theta <= 2 * pi; theta += pi / 360) {
      // 基础波动
      final baseWave = sin(3 * theta + time * 2) * 10;
      
      // 次级波动
      final secondaryWave = cos(5 * theta - time * 1.5) * 5;
      
      // 阻尼波动
      final dampingWave = exp(-0.5 * (theta - pi).abs()) * sin(4 * theta + time) * 8;
      
      // 组合所有波动
      final radius = baseRadius * sizeRate + (baseWave + 
                    secondaryWave + 
                    dampingWave) * max(1 - actionTime,0);

      final x = centerX + radius * cos(theta);
      final y = centerY + radius * sin(theta);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();

    // 绘制主路径
    canvas.drawPath(path, paint);

    // 绘制文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Go',
        style: TextStyle(
          color: Colors.white.withOpacity(min(max(0, actionTime),1)),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void drawStarting(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    final gradient = RadialGradient(
      colors: [
        Colors.red.withOpacity(1 - 0.2 * min(max(0, actionTime),1)),
        Colors.red.withOpacity(1 - 0.4 * min(max(0, actionTime),1)),
        Colors.red.withOpacity(1 - 0.6 * min(max(0, actionTime),1)),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      baseRadius * sizeRate,
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Loading',
        style: TextStyle(
          color: Colors.white.withOpacity(max(0, 1-actionTime)),
          fontSize: 24,
          fontWeight: FontWeight.bold,          
        ),
        
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void drawFailed(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    final gradient = RadialGradient(
      colors: [
        Color.lerp(Colors.red, Colors.grey, max(0, min(1, actionTime)))!.withOpacity(1-0.2*actionTime),
        Color.lerp(Colors.red, Colors.grey, max(0, min(1, actionTime)))!.withOpacity(1-0.4*actionTime),
        Color.lerp(Colors.red, Colors.grey, max(0, min(1, actionTime)))!.withOpacity(1-0.6*actionTime),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      baseRadius * sizeRate,
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Failed',
        style: TextStyle(
          color: Colors.white.withOpacity(max(0, min(1, actionTime))),
          fontSize: 24,
          fontWeight: FontWeight.bold,          
        ),
        
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void drawUnbegin(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      baseRadius,
      paint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Go',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }


  void drawStartingFromFailed(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = min(size.width, size.height) / 3;

    final gradient = RadialGradient(
      colors: [
        Colors.grey.withOpacity(0.8),
        Colors.grey.withOpacity(0.6),
        Colors.grey.withOpacity(0.4),
      ],
      stops: [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 2,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      baseRadius * sizeRate,
      paint,
    );

    var showWords = "Retry";
    if (actionTime.toInt() % 4 == 0) {
      showWords = "Retry";
    } else if (actionTime.toInt() % 4 == 1) {
      showWords = "Retry.";
    } else if (actionTime.toInt() % 4 == 2) {
      showWords = "Retry..";
    } else {
      showWords = "Retry...";
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: showWords,
        style: TextStyle(
          color: Colors.white.withOpacity(max(0, min(1, actionTime))),
          fontSize: 24,
          fontWeight: FontWeight.bold,          
        ),
        
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }


  @override
  void paint(Canvas canvas, Size size) {
    switch (step) {
      case AnimateType.starting:
        drawStarting(canvas, size);
        break;
      case AnimateType.stopping:
        drawStopping(canvas, size);
        break;
      case AnimateType.running:
        drawRunning(canvas, size);
        break;
      case AnimateType.failed:
        drawFailed(canvas, size);
        break;
      case AnimateType.unbegin:
        drawUnbegin(canvas, size);
        break;
      case AnimateType.runningFromFailed:
        drawRunningFromFailed(canvas, size);
        break;
      case AnimateType.startingFromFailed:
        drawStartingFromFailed(canvas, size);
        break;
      case AnimateType.failedAfterRetry:
        drawFailed(canvas, size);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomerButtonPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.randomSeed != randomSeed;
  }

  @override
  bool hitTest(Offset position) {
    // 检查这个位置是否在绘制区域内（例如在圆圈内）
    // 示例：如果你的按钮是一个中心为中点、半径为 100 的圆：
    final center = Offset(200,200);
    return (position - center).distance <= 200;
  }

}