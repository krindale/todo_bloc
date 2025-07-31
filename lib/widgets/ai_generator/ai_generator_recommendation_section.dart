import 'package:flutter/material.dart';
import '../../services/ai_todo_generator_service.dart';
import '../../core/constants/app_constants.dart';

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

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              AppStrings.recommendationsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: LayoutConstants.cardPadding),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: LayoutConstants.smallSpacing,
                runSpacing: LayoutConstants.smallSpacing,
                children: recommendations.map((recommendation) {
                return GestureDetector(
                  onTap: () {
                    print('🔥 GestureDetector 탭 감지: $recommendation');
                    onRecommendationTap(recommendation);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: LayoutConstants.defaultPadding,
                          vertical: LayoutConstants.smallSpacing,
                        ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(LayoutConstants.chipBorderRadius),
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
            ),
            ],
          ),
        ),
      ),
    );
  }
}