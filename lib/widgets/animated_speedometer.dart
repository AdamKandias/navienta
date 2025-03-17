import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AnimatedSpeedometer extends StatefulWidget {
  final double value;
  final double maxValue;
  final double width;
  final double height;

  const AnimatedSpeedometer({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.width = 200,
    this.height = 200,
  });

  @override
  State<AnimatedSpeedometer> createState() => _AnimatedSpeedometerState();
}

class _AnimatedSpeedometerState extends State<AnimatedSpeedometer> {
  double _oldValue = 0.0;

  @override
  void didUpdateWidget(covariant AnimatedSpeedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _oldValue = oldWidget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _oldValue, end: widget.value),
      duration: Duration(milliseconds: 300), // Smooth transition
      curve: Curves.easeInOut,
      builder: (context, animatedValue, child) {
        return CustomPaint(
          size: Size(widget.width.w, widget.height.h), // Adjust size
          painter: SpeedometerPainter(
              value: animatedValue, maxValue: widget.maxValue),
        );
      },
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double value;
  final double maxValue;

  SpeedometerPainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 20.0;
    final double radius = (size.width / 2) - strokeWidth;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint backgroundPaint = Paint()
      ..color = Color(0xFFC4D8E7) // Default light blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double progressAngle =
        pi * (value / maxValue); // Convert value to angle

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start from left
      pi, // Half-circle (180 degrees)
      false,
      backgroundPaint,
    );

    if (value > 0) {
      final Paint gradientPaint = Paint()
        ..shader = SweepGradient(
          startAngle: pi,
          endAngle: pi + progressAngle,
          colors: value == maxValue
              ? [AppColors.primary, AppColors.primary]
              : [
                  AppColors.primary,
                  AppColors.primary.withAlpha(200), // Mid-transition
                  Color(0xFFC4D8E7), // Fade into default background
                ],
          stops: value == maxValue
              ? [0.0, 1.0]
              : [
                  0.0,
                  0.7 * (value / maxValue), // Mid-transition at 70% of value
                  1.0,
                ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw animated progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        progressAngle, // Draw only up to the value
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
