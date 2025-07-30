import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(16.0),
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
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controller,
                maxLines: hasResults ? 1 : 3,
                decoration: InputDecoration(
                  hintText: hasResults
                      ? '새로운 요청을 입력하세요'
                      : '예: 건강을 위한 플랜을 짜줘, 새로운 기술을 배우고 싶어',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: hasResults ? 8 : 16),
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
                label: Text(isGenerating ? 'AI가 생각 중...' : 'AI로 할 일 생성'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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