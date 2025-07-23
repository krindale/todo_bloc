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
    CategoryData(label: 'Work', color: Colors.purple),
    CategoryData(label: 'Personal', color: Colors.grey),
    CategoryData(label: 'Shopping', color: Colors.blueGrey),
    CategoryData(label: 'Health', color: Colors.green),
    CategoryData(label: 'Finance', color: Colors.blue),
    CategoryData(label: 'Travel', color: Colors.orange),
    CategoryData(label: 'Family', color: Colors.brown),
    CategoryData(label: 'Social', color: Colors.cyan),
  ];

  List<CategoryData> getCategories() {
    return defaultCategories;
  }
}