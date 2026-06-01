import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ExamCountdownWidget extends StatefulWidget {
  const ExamCountdownWidget({super.key});

  @override
  State<ExamCountdownWidget> createState() => _ExamCountdownWidgetState();
}

class _ExamCountdownWidgetState extends State<ExamCountdownWidget> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = AppConstants.examDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _timeLeft = AppConstants.examDate.difference(DateTime.now()));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getUrgencyColor() {
    final days = _timeLeft.inDays;
    if (days > 90) return AppColors.success;
    if (days > 30) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final color = _getUrgencyColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.primaryNavyLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.event, color: color, size: 24),
              const SizedBox(width: 8),
              const Text('Exam Countdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  days > 90 ? 'Plenty of time' : days > 30 ? 'Stay focused!' : 'Hurry up!',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CountdownUnit(value: '$days', label: 'Days', color: color),
              Text(':', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 28, fontWeight: FontWeight.bold)),
              _CountdownUnit(value: hours.toString().padLeft(2, '0'), label: 'Hours', color: color),
              Text(':', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 28, fontWeight: FontWeight.bold)),
              _CountdownUnit(value: minutes.toString().padLeft(2, '0'), label: 'Minutes', color: color),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 1 - (days / 365).clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CountdownUnit({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(value, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}
