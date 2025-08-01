/// **간단한 캘린더 테스트**
/// 
/// 기본적인 캘린더 화면 렌더링을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';

void main() {
  group('Simple Calendar Tests', () {
    /// 기본 캘린더 화면 렌더링 테스트
    testWidgets('renders calendar screen without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // 로딩 상태에서 시작
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 데이터 로드 완료 대기 (최대 10초)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 위젯이 에러 없이 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// CalendarHeader 기본 테스트
    testWidgets('calendar header renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 캘린더 헤더가 렌더링되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });
  });
}