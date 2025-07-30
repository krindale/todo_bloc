import 'package:flutter/material.dart';
import '../../services/ai_todo_generator_service.dart';

class AiGeneratorRecommendationSection extends StatelessWidget {
  final Function(String) onRecommendationTap;

  const AiGeneratorRecommendationSection({
    super.key,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    final aiService = AiTodoGeneratorService();
    final recommendations = aiService.getSuggestedRequests();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추천 요청',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendations.map((recommendation) {
                return GestureDetector(
                  onTap: () {
                    print('🔥 GestureDetector 탭 감지: $recommendation');
                    onRecommendationTap(recommendation);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}