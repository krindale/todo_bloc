import 'package:flutter/material.dart';
import 'category_chip.dart';
import '../../data/category_data.dart';

/// 작업 카테고리 섹션을 표시하는 위젯
class CategorySection extends StatelessWidget {
  final List<CategoryData> categories;

  const CategorySection({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: categories
              .map((category) => CategoryChip(
                    label: category.label,
                    color: category.color,
                  ))
              .toList(),
        ),
      ],
    );
  }
} 