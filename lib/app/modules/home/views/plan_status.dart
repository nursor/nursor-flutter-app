import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('MM/dd');

String formatDate(DateTime date) {
  return formatter.format(date);
}

class PlanStatusItem extends StatelessWidget {
  final String text;
  final double width;
  final double progress;
  const PlanStatusItem({super.key, required this.text, required this.width, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Container(
                  child: Text(
                    text, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.bold),),
                ),
              ),
              // 进度条背景
              Positioned(
                top: 16,
                child: Container(
                width: width,
                height: 5,
                decoration: BoxDecoration(
                color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              ),
              Positioned(
                top: 16,
                child: Container(
                width: width * progress,
                height: 5,
                decoration: BoxDecoration(
                color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
            ],
          ),
    );
  }
}

class PlanStatus extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;

  final int planCount;
  final int planUsed;

  final double width;
  const PlanStatus({super.key, required this.startTime, required this.endTime, required this.width, required this.planCount, required this.planUsed});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isRunning = now.isAfter(startTime) && now.isBefore(endTime);

    final progress = isRunning ? (now.difference(startTime).inSeconds / endTime.difference(startTime).inSeconds) : 0.0;
    final progressUsage = planCount>0? planUsed / planCount: 0.0;

    return Container(
      width: width,
      height: 50,
      child: Stack(
        children: [
          // 进度条
          Positioned(
            top: 0,
            child: Container(
              child: PlanStatusItem(text: '日期: ${formatDate(startTime)} ~ ${formatDate(endTime)}', width: width, progress: progress),
            ),
          ),
          
          // 剩余计划
          Positioned(
            top: 25,
            child: Container(
              child: PlanStatusItem(text: '用量: $planUsed/${planCount>10000?"infinity":planCount}', width: width, progress: progressUsage),
            ),
          ),
        ],
      ),
    );
  }
} 