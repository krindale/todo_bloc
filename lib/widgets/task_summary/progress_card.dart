import 'package:flutter/material.dart';
import '../../data/category_data.dart';
import '../common/ring_chart.dart';

/// 카테고리별 작업 진행률을 링 차트로 표시하는 카드 위젯
class ProgressCard extends StatelessWidget {
  final Map<String, int> categoryTaskCounts;
  final Map<String, int> categoryCompletionCounts;
  final List<CategoryData> categories;

  const ProgressCard({
    Key? key,
    required this.categoryTaskCounts,
    required this.categoryCompletionCounts,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesWithTasks = categories.where((category) {
      final totalTasks = categoryTaskCounts[category.label] ?? 0;
      return totalTasks > 0;
    }).toList();

    if (categoriesWithTasks.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Category Progress',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              Text('No tasks available',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildRingChartGrid(categoriesWithTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildRingChartGrid(List<CategoryData> categoriesWithTasks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final itemSpacing = 16.0;
          
          // 한 줄에 최대 3개까지만 표시
          int itemsPerRow = categoriesWithTasks.length.clamp(1, 3);
          
          // 실제 아이템 너비 계산 (전체 가로 공간을 균등 분할)
          final itemWidth = (screenWidth - (itemsPerRow - 1) * itemSpacing) / itemsPerRow;

          return Wrap(
            spacing: itemSpacing,
            runSpacing: 20.0,
            children: categoriesWithTasks.map((category) => 
              _buildCategoryRingChart(category, itemWidth)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRingChart(CategoryData category, double itemWidth) {
    final totalTasks = categoryTaskCounts[category.label] ?? 0;
    final completedTasks = categoryCompletionCounts[category.label] ?? 0;
    final progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Container(
      width: itemWidth,
      child: Column(
        children: [
          RingChart(
            progress: progress,
            color: category.color,
            size: 80.0,
            strokeWidth: 6.0,
            centerWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$progressPercentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
                Text(
                  '$completedTasks/$totalTasks',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
