import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AiGeneratorHeader extends StatelessWidget {
  const AiGeneratorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: LayoutConstants.smallSpacing),
            Text(
              AppStrings.aiGeneratorTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: LayoutConstants.smallSpacing / 2),
            Text(
              AppStrings.aiGeneratorDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
