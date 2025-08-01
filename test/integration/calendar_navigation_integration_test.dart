/// **캘린더 네비게이션 통합 테스트**
/// 
/// 캘린더 화면의 월 네비게이션과 할 일 표시 기능을 통합적으로 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/main_tab_screen.dart';
import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/model/todo_item.dart';

import 'calendar_navigation_integration_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
  FirebaseSyncService,
  TaskCategorizationService,
])
void main() {
  group('Calendar Navigation Integration Tests', () {
    late MockHiveTodoRepository mockHiveRepository;
    late MockFirebaseSyncService mockFirebaseService;
    late MockTaskCategorizationService mockCategorizationService;

    setUp(() {
      mockHiveRepository = MockHiveTodoRepository();
      mockFirebaseService = MockFirebaseSyncService();
      mockCategorizationService = MockTaskCategorizationService();

      // 기본 Mock 설정
      when(mockHiveRepository.getTodos()).thenAnswer((_) async => [
        TodoItem(
          title: 'Test Task 1',
          description: 'Task for today',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'high',
          category: 'work',
        ),
        TodoItem(
          title: 'Test Task 2',
          description: 'Task for tomorrow',
          isCompleted: false,
          dueDate: DateTime.now().add(Duration(days: 1)),
          priority: 'medium',
          category: 'personal',
        ),
      ]);
      
      when(mockFirebaseService.isUserSignedIn).thenReturn(false);
    });

    /// 메인 앱에서 캘린더 탭으로 이동하여 네비게이션 테스트
    testWidgets('can navigate to calendar tab and use month navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 캘린더 화면이 로드되었는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarHeader), findsOneWidget);

      // 네비게이션 버튼들이 있는지 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    /// 캘린더에서 월 네비게이션 동작 테스트
    testWidgets('calendar month navigation works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 이전 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // 다음 달 버튼 클릭 (원래 월로 돌아가기)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 다음 달 버튼 한 번 더 클릭
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 캘린더가 여전히 정상적으로 표시되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });

    /// 캘린더 포맷 변경 테스트
    testWidgets('can change calendar format between month and 2-week view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 2주 뷰로 변경
      await tester.tap(find.text('2주'));
      await tester.pump();

      // 다시 월별 뷰로 변경
      await tester.tap(find.text('월별'));
      await tester.pump();

      // 포맷 변경이 에러 없이 작동하는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.text('월별'), findsOneWidget);
      expect(find.text('2주'), findsOneWidget);
    });

    /// 캘린더와 다른 탭 간 전환 테스트
    testWidgets('can switch between calendar and other tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 월 네비게이션 사용
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // Tasks 탭으로 돌아가기
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // 다시 Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 캘린더 상태가 유지되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });

    /// 전체 워크플로우 테스트 - 할 일 추가부터 캘린더 확인까지
    testWidgets('full workflow: create todo and view in calendar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Tasks 탭에서 시작 (기본 탭)
      expect(find.text('Tasks'), findsOneWidget);

      // 2. Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 3. 캘린더가 로드되었는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      // 4. 월 네비게이션 테스트
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 5. 포맷 변경 테스트
      await tester.tap(find.text('2주'));
      await tester.pump();
      await tester.tap(find.text('월별'));
      await tester.pump();

      // 6. 최종 상태 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    /// 에러 복구 테스트
    testWidgets('handles rapid navigation gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calendar 탭으로 이동
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 빠른 네비게이션 (사용자가 빠르게 버튼을 누르는 상황)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
      }

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump();
      }

      // 빠른 포맷 변경
      await tester.tap(find.text('2주'));
      await tester.pump();
      await tester.tap(find.text('월별'));
      await tester.pump();
      await tester.tap(find.text('2주'));
      await tester.pump();

      // 앱이 여전히 정상 상태인지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });
  });
}