import 'package:flutter/material.dart';

/// 작업 정보 아이템을 표시하는 위젯
class TaskInfoItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const TaskInfoItem({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
} 