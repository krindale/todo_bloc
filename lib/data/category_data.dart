import 'package:flutter/material.dart';

class CategoryData {
  final String label;
  final Color color;

  const CategoryData({
    required this.label,
    required this.color,
  });
}

class CategoryProvider {
  static const List<CategoryData> defaultCategories = [
    CategoryData(label: 'Work', color: Color(0xFF6366F1)),        // 세련된 인디고
    CategoryData(label: 'Personal', color: Color(0xFF8B5CF6)),    // 보라색 (개인)
    CategoryData(label: 'Shopping', color: Color(0xFFEC4899)),    // 핑크 (쇼핑)
    CategoryData(label: 'Health', color: Color(0xFF10B981)),      // 에메랄드 (건강)
    CategoryData(label: 'Finance', color: Color(0xFF3B82F6)),     // 파란색 (금융)
    CategoryData(label: 'Travel', color: Color(0xFFF59E0B)),      // 황금색 (여행)
    CategoryData(label: 'Family', color: Color(0xFFEF4444)),      // 빨간색 (가족)
    CategoryData(label: 'Social', color: Color(0xFF06B6D4)),      // 시안 (소셜)
  ];

  List<CategoryData> getCategories() {
    return defaultCategories;
  }
}