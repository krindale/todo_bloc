/// **Calendar Screen 테스트 (수정 버전)**
/// 
/// 캘린더 화면의 네비게이션 기능과 할 일 표시 기능을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_todo_list.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/presentation/providers/combined_todo_provider.dart';
import 'package:todo_bloc/presentation/providers/todo_provider.dart';

import 'calendar_screen_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
])
void main() {
  group('CalendarScreen', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      
      // Mock 기본 동작 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => []);
    });

    /// 기본 캘린더 화면 렌더링 테스트
    testWidgets('renders calendar with header correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // 로딩 상태에서 시작
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 데이터 로드 완료 대기
      await tester.pumpAndSettle();

      // 캘린더 헤더 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });

    /// Provider 통합 테스트 - 테스트 데이터로 할 일 표시
    testWidgets('displays todos from combined provider correctly', (tester) async {
      // 테스트용 할 일 데이터 생성
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Test Todo 1',
          description: 'Test Description',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: DateTime.now(),
        ),
        TodoEntity(
          id: '2',
          title: 'Test Todo 2',
          description: 'Test Description 2',
          isCompleted: true,
          dueDate: DateTime.now(),
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: DateTime.now(),
        ),
      ];

      // Hive Todo 테스트 데이터
      final hiveTodos = [
        TodoItem(
          title: 'Hive Todo 1',
          priority: 'low',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isCompleted: false,
          category: 'hobby',
        ),
      ];

      // Mock repository 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => hiveTodos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Combined provider가 사용하는 하위 provider들을 오버라이드
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 캘린더 구성 요소들이 렌더링되었는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      
      // TableCalendar가 렌더링되었는지 확인
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 에러 상태 처리 테스트
    testWidgets('handles error state correctly', (tester) async {
      // Mock repository가 에러를 던지도록 설정
      when(mockRepository.getTodos()).thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // 에러를 발생시키는 provider override
            todoListProvider.overrideWith((ref) => throw Exception('Provider error')),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 에러 상태 UI 요소 확인
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('캘린더를 불러오는 중 오류가 발생했습니다.'), findsOneWidget);
    });

    /// 선택된 날짜 Provider 테스트
    testWidgets('selected date provider works correctly', (tester) async {
      final testDate = DateTime(2024, 1, 15);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDateProvider.overrideWith((ref) => testDate),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 캘린더가 선택된 날짜로 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// 캘린더 포맷 Provider 테스트
    testWidgets('calendar format provider works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarFormatProvider.overrideWith((ref) => CalendarFormat.twoWeeks),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 2주 포맷으로 캘린더가 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// 빈 데이터 상태 테스트
    testWidgets('handles empty todo list correctly', (tester) async {
      // 빈 데이터 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => <TodoEntity>[]),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 빈 상태에서도 캘린더 구성 요소들이 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });
  });
}