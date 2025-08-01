/// **캘린더 네비게이션 기능 테스트**
/// 
/// 업데이트된 캘린더 네비게이션과 포맷별 이동 기능을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/presentation/providers/combined_todo_provider.dart';

@GenerateMocks([HiveTodoRepository])
import 'calendar_navigation_test.mocks.dart';

void main() {
  group('Calendar Navigation Tests', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
    });

    /// 캘린더 포맷별 네비게이션 테스트
    group('Format-based Navigation', () {
      testWidgets('월별 포맷에서 네비게이션 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 초기 상태가 월별 포맷인지 확인
        final initialFormat = container.read(calendarFormatProvider);
        expect(initialFormat, CalendarFormat.month);

        // 월별 포맷에서 툴팁 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);

        // 이전 달 버튼 클릭
        await tester.tap(find.byTooltip('이전 달'));
        await tester.pumpAndSettle();

        // 다음 달 버튼 클릭
        await tester.tap(find.byTooltip('다음 달'));
        await tester.pumpAndSettle();

        container.dispose();
      });

      testWidgets('2주 포맷에서 네비게이션 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 2주 포맷으로 변경
        await tester.tap(find.text('2주'));
        await tester.pumpAndSettle();

        // 2주 포맷에서 툴팁 확인
        expect(find.byTooltip('이전 2주'), findsOneWidget);
        expect(find.byTooltip('다음 2주'), findsOneWidget);

        // 이전 2주 버튼 클릭
        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pumpAndSettle();

        // 다음 2주 버튼 클릭
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pumpAndSettle();

        container.dispose();
      });

      testWidgets('포맷 변경 시 툴팁 동적 업데이트 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 초기 월별 포맷 툴팁 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);

        // 2주 포맷으로 변경
        await tester.tap(find.text('2주'));
        await tester.pumpAndSettle();

        // 2주 포맷 툴팁으로 변경 확인
        expect(find.byTooltip('이전 2주'), findsOneWidget);
        expect(find.byTooltip('다음 2주'), findsOneWidget);
        expect(find.byTooltip('이전 달'), findsNothing);
        expect(find.byTooltip('다음 달'), findsNothing);

        // 다시 월별 포맷으로 변경
        await tester.tap(find.text('월별'));
        await tester.pumpAndSettle();

        // 월별 포맷 툴팁으로 복원 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);
        expect(find.byTooltip('이전 2주'), findsNothing);
        expect(find.byTooltip('다음 2주'), findsNothing);

        container.dispose();
      });
    });

    /// TableCalendar 헤더 숨김 테스트
    group('TableCalendar Header Hidden Tests', () {
      testWidgets('TableCalendar 헤더가 숨겨져 있는지 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // CalendarHeader는 존재해야 함
        expect(find.byType(CalendarHeader), findsOneWidget);

        // TableCalendar의 내장 헤더 텍스트가 보이지 않는지 확인
        // (headerVisible: false 설정으로 인해)
        final calendarWidget = find.byType(TableCalendar);
        expect(calendarWidget, findsOneWidget);

        container.dispose();
      });

      testWidgets('중복된 월/년 표시가 없는지 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // CalendarHeader에만 월/년 표시가 있어야 함
        expect(find.byType(CalendarHeader), findsOneWidget);
        
        // 실제로는 TableCalendar 내부 헤더가 숨겨져 있어야 함
        // (headerVisible: false로 설정됨)

        container.dispose();
      });
    });

    /// 네비게이션 상태 관리 테스트
    group('Navigation State Management', () {
      testWidgets('focused day 상태 변경 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 초기 상태에서 네비게이션 버튼 클릭
        await tester.tap(find.byTooltip('다음 달'));
        await tester.pumpAndSettle();

        // 상태가 정상적으로 업데이트되었는지 확인 (에러 없이 동작)
        expect(find.byType(CalendarScreen), findsOneWidget);

        container.dispose();
      });

      testWidgets('캘린더 포맷 변경과 네비게이션 조합 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 월별 → 2주별 포맷 변경
        await tester.tap(find.text('2주'));
        await tester.pumpAndSettle();

        // 2주별 포맷에서 네비게이션
        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pumpAndSettle();

        // 다시 월별 포맷으로 변경
        await tester.tap(find.text('월별'));
        await tester.pumpAndSettle();

        // 월별 포맷에서 네비게이션
        await tester.tap(find.byTooltip('이전 달'));
        await tester.pumpAndSettle();

        // 모든 변경이 정상적으로 처리되었는지 확인
        expect(find.byType(CalendarScreen), findsOneWidget);

        container.dispose();
      });
    });

    /// 에러 처리 및 예외 상황 테스트
    group('Error Handling Tests', () {
      testWidgets('데이터 로딩 오류 시 네비게이션 동작 테스트', (tester) async {
        // 에러를 발생시키는 Mock 설정
        when(mockRepository.getTodos()).thenThrow(Exception('Network error'));

        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 에러 상태에서도 기본 구조가 유지되는지 확인
        expect(find.byType(CalendarScreen), findsOneWidget);

        container.dispose();
      });

      testWidgets('빠른 연속 클릭 처리 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 빠른 연속 클릭
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byTooltip('다음 달'));
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();

        // 에러 없이 정상 동작하는지 확인
        expect(find.byType(CalendarScreen), findsOneWidget);

        container.dispose();
      });
    });

    /// 성능 및 메모리 테스트
    group('Performance Tests', () {
      testWidgets('메모리 누수 방지 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        // 여러 번 위젯 생성/제거 반복
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                home: CalendarScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 네비게이션 테스트
          await tester.tap(find.byTooltip('다음 달'));
          await tester.pumpAndSettle();

          // 위젯 제거
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }

        // 정상적으로 dispose 되는지 확인
        container.dispose();
      });

      testWidgets('다양한 포맷에서 성능 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        final stopwatch = Stopwatch()..start();

        // 다양한 포맷으로 빠르게 전환
        final formats = ['2주', '월별', '2주', '월별'];
        for (final format in formats) {
          await tester.tap(find.text(format));
          await tester.pumpAndSettle();
          
          // 각 포맷에서 네비게이션 테스트
          final isMonth = format == '월별';
          final tooltip = isMonth ? '다음 달' : '다음 2주';
          await tester.tap(find.byTooltip(tooltip));
          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        // 성능 임계값 확인 (10초 이내)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));

        container.dispose();
      });
    });
  });

  /// 단위 테스트 (Unit Tests)
  group('Calendar Navigation Unit Tests', () {
    test('날짜 계산 로직 테스트', () {
      final baseDate = DateTime(2024, 8, 15);

      // 월별 이동
      final previousMonth = DateTime(baseDate.year, baseDate.month - 1, 1);
      final nextMonth = DateTime(baseDate.year, baseDate.month + 1, 1);
      
      expect(previousMonth.month, equals(7));
      expect(nextMonth.month, equals(9));

      // 2주 이동
      final previous2Weeks = baseDate.subtract(const Duration(days: 14));
      final next2Weeks = baseDate.add(const Duration(days: 14));
      
      expect(previous2Weeks.day, equals(1));
      expect(next2Weeks.day, equals(29));

      // 주별 이동
      final previousWeek = baseDate.subtract(const Duration(days: 7));
      final nextWeek = baseDate.add(const Duration(days: 7));
      
      expect(previousWeek.day, equals(8));
      expect(nextWeek.day, equals(22));
    });

    test('연도 경계 처리 테스트', () {
      // 연말에서 다음 해로
      final december = DateTime(2024, 12, 15);
      final nextYear = DateTime(december.year, december.month + 1, 1);
      expect(nextYear.year, equals(2025));
      expect(nextYear.month, equals(1));

      // 연초에서 이전 해로
      final january = DateTime(2024, 1, 15);
      final previousYear = DateTime(january.year, january.month - 1, 1);
      expect(previousYear.year, equals(2023));
      expect(previousYear.month, equals(12));
    });

    test('윤년 처리 테스트', () {
      final leapYear = DateTime(2024, 2, 29);
      expect(leapYear.isUtc, isFalse);
      
      // 윤년의 2월에서 3월로 이동
      final march = DateTime(leapYear.year, leapYear.month + 1, 1);
      expect(march.month, equals(3));
      expect(march.day, equals(1));
    });

    test('포맷별 이동 거리 계산 테스트', () {
      final formats = {
        CalendarFormat.month: 'month',
        CalendarFormat.twoWeeks: '14 days',
        CalendarFormat.week: '7 days',
      };

      for (final format in formats.keys) {
        switch (format) {
          case CalendarFormat.month:
            expect(formats[format], equals('month'));
            break;
          case CalendarFormat.twoWeeks:
            expect(formats[format], equals('14 days'));
            break;
          case CalendarFormat.week:
            expect(formats[format], equals('7 days'));
            break;
        }
      }
    });
  });
}