import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/data/category_data.dart';

void main() {
  group('CategoryProvider', () {
    late CategoryProvider provider;

    setUp(() {
      provider = CategoryProvider();
    });

    test('should return default categories', () {
      final categories = provider.getCategories();
      
      expect(categories.length, 8);
      expect(categories.first.label, 'Work');
      expect(categories.first.color, Colors.purple);
    });

    test('should return consistent categories', () {
      final categories1 = provider.getCategories();
      final categories2 = provider.getCategories();
      
      expect(categories1.length, categories2.length);
      expect(categories1.first.label, categories2.first.label);
    });
  });

  group('CategoryData', () {
    test('should create category data with required fields', () {
      const category = CategoryData(
        label: 'Test Category',
        color: Colors.red,
      );
      
      expect(category.label, 'Test Category');
      expect(category.color, Colors.red);
    });
  });
}