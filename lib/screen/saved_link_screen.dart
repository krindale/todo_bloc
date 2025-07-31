/// **저장된 링크 화면**
/// 
/// 사용자가 저장한 링크들을 표시하고 관리하는 화면입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedLinkScreen extends ConsumerStatefulWidget {
  const SavedLinkScreen({super.key});

  @override
  ConsumerState<SavedLinkScreen> createState() => _SavedLinkScreenState();
}

class _SavedLinkScreenState extends ConsumerState<SavedLinkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 링크',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 기능은 곧 추가될 예정입니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}