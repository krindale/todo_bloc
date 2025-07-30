import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AiGeneratorErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const AiGeneratorErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: LayoutConstants.defaultSpacing),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.defaultSpacing),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}