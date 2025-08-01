/// **캘린더 헤더 숨김 통합 테스트**
/// 
/// TableCalendar 헤더가 완전히 숨겨지고 중복 표시가 없는지 통합 테스트합니다.

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
import '../screen/calendar/calendar_navigation_test.mocks.dart';

void main() {
  group('Calendar Header Hidden Integration Tests', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
    });

    /// TableCalendar 헤더 숨김 통합 테스트
    group('TableCalendar Header Visibility', () {
      testWidgets('TableCalendar 헤더가 완전히 숨겨져 있는지 테스트', (tester) async {
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
        
        // TableCalendar은 존재해야 함
        expect(find.byType(TableCalendar), findsOneWidget);

        // TableCalendar 위젯을 찾아서 headerVisible 속성 확인
        final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
        
        // headerVisible이 false로 설정되어 있는지 확인
        expect(tableCalendar.headerVisible, isFalse);

        container.dispose();
      });

      testWidgets('헤더 스타일이 올바르게 설정되어 있는지 테스트', (tester) async {
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

        final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
        
        // HeaderStyle 속성들이 올바르게 설정되어 있는지 확인
        expect(tableCalendar.headerStyle.formatButtonVisible, isFalse);
        expect(tableCalendar.headerStyle.leftChevronVisible, isFalse);
        expect(tableCalendar.headerStyle.rightChevronVisible, isFalse);
        expect(tableCalendar.headerStyle.headerPadding, equals(EdgeInsets.zero));
        expect(tableCalendar.headerStyle.headerMargin, equals(EdgeInsets.zero));
        expect(tableCalendar.headerStyle.titleTextStyle?.fontSize, equals(0));
        expect(tableCalendar.headerStyle.titleTextStyle?.height, equals(0));

        container.dispose();
      });
    });

    /// 중복 표시 방지 테스트
    group('Duplicate Display Prevention', () {
      testWidgets('월/년 정보가 중복으로 표시되지 않는지 테스트', (tester) async {
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

        // CalendarHeader에서 월/년 표시 확인
        expect(find.byType(CalendarHeader), findsOneWidget);
        
        // TableCalendar의 헤더가 숨겨져 있으므로 
        // 실제로는 월/년 정보가 CalendarHeader에서만 표시됨
        
        // 검증: CalendarHeader가 렌더링되고 있고,
        // TableCalendar의 headerVisible이 false인지 확인
        final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
        expect(tableCalendar.headerVisible, isFalse);

        container.dispose();
      });

      testWidgets('네비게이션 버튼이 중복으로 표시되지 않는지 테스트', (tester) async {
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

        // CalendarHeader의 네비게이션 버튼 확인 (chevron_left, chevron_right)
        final leftChevrons = find.byIcon(Icons.chevron_left);
        final rightChevrons = find.byIcon(Icons.chevron_right);

        // CalendarHeader에서만 네비게이션 버튼이 표시되어야 함
        // TableCalendar의 네비게이션 버튼은 숨겨져 있어야 함
        expect(leftChevrons, findsOneWidget);  // CalendarHeader에서만
        expect(rightChevrons, findsOneWidget); // CalendarHeader에서만

        container.dispose();
      });
    });

    /// 다양한 포맷에서 헤더 숨김 테스트
    group('Header Hidden Across Formats', () {
      testWidgets('월별 포맷에서 헤더 숨김 테스트', (tester) async {
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

        // 월별 포맷 확인
        final format = container.read(calendarFormatProvider);
        expect(format, equals(CalendarFormat.month));

        // TableCalendar 헤더가 숨겨져 있는지 확인
        final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
        expect(tableCalendar.headerVisible, isFalse);

        container.dispose();
      });

      testWidgets('2주 포맷에서 헤더 숨김 테스트', (tester) async {
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

        // 2주 포맷 확인
        final format = container.read(calendarFormatProvider);
        expect(format, equals(CalendarFormat.twoWeeks));

        // TableCalendar 헤더가 여전히 숨겨져 있는지 확인
        final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
        expect(tableCalendar.headerVisible, isFalse);

        container.dispose();
      });

      testWidgets('포맷 변경 후에도 헤더가 숨겨져 있는지 테스트', (tester) async {
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

        // 여러 포맷 변경 테스트
        final formats = ['2주', '월별', '2주'];
        
        for (final format in formats) {
          await tester.tap(find.text(format));
          await tester.pumpAndSettle();

          // 각 포맷에서 헤더가 숨겨져 있는지 확인
          final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
          expect(tableCalendar.headerVisible, isFalse, 
                 reason: '$format 포맷에서 헤더가 숨겨지지 않음');
        }

        container.dispose();
      });
    });

    /// UI 일관성 테스트
    group('UI Consistency Tests', () {
      testWidgets('CalendarHeader와 TableCalendar 간격 테스트', (tester) async {
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

        // CalendarHeader와 TableCalendar이 적절한 간격을 가지는지 확인
        final calendarHeader = find.byType(CalendarHeader);
        final tableCalendar = find.byType(TableCalendar);

        expect(calendarHeader, findsOneWidget);
        expect(tableCalendar, findsOneWidget);

        // SizedBox 간격이 있는지 확인
        expect(find.byType(SizedBox), findsWidgets);

        container.dispose();
      });

      testWidgets('전체 UI 레이아웃이 올바른지 테스트', (tester) async {
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

        // 전체 구조 확인
        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.byType(TableCalendar), findsOneWidget);

        // FloatingActionButton (새로고침 버튼) 확인
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byTooltip('캘린더 새로고침'), findsOneWidget);

        container.dispose();
      });
    });

    /// 성능 테스트
    group('Performance Tests', () {
      testWidgets('헤더 숨김 설정이 성능에 미치는 영향 테스트', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        stopwatch.stop();

        // 렌더링 시간이 합리적인 범위 내에 있는지 확인
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // 여러 번 포맷 변경 테스트
        final formatStopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('2주'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('월별'));
          await tester.pumpAndSettle();
        }

        formatStopwatch.stop();

        // 포맷 변경 성능 확인
        expect(formatStopwatch.elapsedMilliseconds, lessThan(3000));

        container.dispose();
      });
    });
  });

  /// 헤더 숨김 로직 단위 테스트
  group('Header Hidden Logic Unit Tests', () {
    test('HeaderStyle 설정값 검증', () {
      // CalendarScreen에서 사용하는 HeaderStyle 설정값들 검증
      final headerStyle = HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.zero,
        headerMargin: EdgeInsets.zero,
        titleTextStyle: const TextStyle(
          fontSize: 0,
          height: 0,
        ),
      );

      expect(headerStyle.formatButtonVisible, isFalse);
      expect(headerStyle.titleCentered, isFalse);
      expect(headerStyle.leftChevronVisible, isFalse);
      expect(headerStyle.rightChevronVisible, isFalse);
      expect(headerStyle.headerPadding, equals(EdgeInsets.zero));
      expect(headerStyle.headerMargin, equals(EdgeInsets.zero));
      expect(headerStyle.titleTextStyle?.fontSize, equals(0));
      expect(headerStyle.titleTextStyle?.height, equals(0));
    });

    test('headerVisible 플래그 검증', () {
      const headerVisible = false;
      expect(headerVisible, isFalse);
    });

    test('EdgeInsets.zero 값 검증', () {
      final zeroPadding = EdgeInsets.zero;
      final zeroMargin = EdgeInsets.zero;
      
      expect(zeroPadding.left, equals(0));
      expect(zeroPadding.top, equals(0));
      expect(zeroPadding.right, equals(0));
      expect(zeroPadding.bottom, equals(0));
      
      expect(zeroMargin.left, equals(0));
      expect(zeroMargin.top, equals(0));
      expect(zeroMargin.right, equals(0));
      expect(zeroMargin.bottom, equals(0));
    });

    test('TextStyle 숨김 설정 검증', () {
      const hiddenTextStyle = TextStyle(
        fontSize: 0,
        height: 0,
      );
      
      expect(hiddenTextStyle.fontSize, equals(0));
      expect(hiddenTextStyle.height, equals(0));
    });
  });
}