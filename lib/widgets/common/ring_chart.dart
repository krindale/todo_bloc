import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 링(도넛) 차트 위젯
class RingChart extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  final Color color;
  final Color backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;
  final bool animate;

  const RingChart({
    Key? key,
    required this.progress,
    required this.color,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.centerWidget,
    this.animate = true,
  }) : super(key: key);

  @override
  _RingChartState createState() => _RingChartState();
}

class _RingChartState extends State<RingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(RingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: RingChartPainter(
                  progress: widget.animate ? _animation.value : widget.progress,
                  color: widget.color,
                  backgroundColor: widget.backgroundColor,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          if (widget.centerWidget != null) widget.centerWidget!,
        ],
      ),
    );
  }
}

class RingChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  RingChartPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RingChartPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.backgroundColor != backgroundColor ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}