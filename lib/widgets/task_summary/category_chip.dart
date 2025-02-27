import 'package:flutter/material.dart';

/// 카테고리 칩 위젯
class CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
} 