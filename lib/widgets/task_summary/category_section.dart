import 'package:flutter/material.dart';
import 'category_chip.dart';

/// 작업 카테고리 섹션을 표시하는 위젯
class CategorySection extends StatelessWidget {
  const CategorySection({Key? key}) : super(key: key);

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
          children: const [
            CategoryChip(label: 'Work', color: Colors.purple),
            CategoryChip(label: 'Personal', color: Colors.grey),
            CategoryChip(label: 'Shopping', color: Colors.blueGrey),
            CategoryChip(label: 'Health', color: Colors.green),
            CategoryChip(label: 'Finance', color: Colors.blue),
            CategoryChip(label: 'Travel', color: Colors.orange),
            CategoryChip(label: 'Family', color: Colors.brown),
            CategoryChip(label: 'Social', color: Colors.cyan),
          ],
        ),
      ],
    );
  }
} 