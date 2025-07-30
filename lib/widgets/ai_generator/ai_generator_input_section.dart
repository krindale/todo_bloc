import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AiGeneratorInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final bool hasResults;
  final VoidCallback onGenerate;

  const AiGeneratorInputSection({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.hasResults,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasResults) ...[
                Text(
                  '어떤 일을 도와드릴까요?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: LayoutConstants.cardPadding),
              ],
              TextField(
                controller: controller,
                maxLines: hasResults ? 1 : 3,
                decoration: InputDecoration(
                  hintText: hasResults
                      ? AppStrings.newRequestPlaceholder
                      : AppStrings.aiRequestPlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LayoutConstants.defaultBorderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.defaultPadding,
                    vertical: LayoutConstants.cardPadding,
                  ),
                ),
              ),
              SizedBox(height: hasResults ? LayoutConstants.smallSpacing : LayoutConstants.defaultSpacing),
              ElevatedButton.icon(
                onPressed: isGenerating ? null : onGenerate,
                icon: isGenerating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(isGenerating ? AppStrings.generating : AppStrings.generateButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: LayoutConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LayoutConstants.defaultBorderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}