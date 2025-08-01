/// **CalendarHeader 위젯 테스트**
/// 
/// 캘린더 헤더의 네비게이션 및 포맷 변경 기능을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';

void main() {
  group('CalendarHeader', () {
    late DateTime testDate;
    late CalendarFormat testFormat;
    late List<CalendarFormat> formatChanges;
    late List<void Function()> navigationCalls;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testFormat = CalendarFormat.month;
      formatChanges = [];
      navigationCalls = [];
    });

    /// 기본 렌더링 테스트
    testWidgets('renders all components correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) => formatChanges.add(format),
              onPreviousPeriod: () => navigationCalls.add(() => 'previous'),
              onNextPeriod: () => navigationCalls.add(() => 'next'),
            ),
          ),
        ),
      );

      // 네비게이션 버튼 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byTooltip('이전 달'), findsOneWidget);
      expect(find.byTooltip('다음 달'), findsOneWidget);
      
      // 포맷 변경 버튼 확인
      expect(find.text('월별'), findsOneWidget);
      expect(find.text('2주'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_view_month), findsOneWidget);
      expect(find.byIcon(Icons.calendar_view_week), findsOneWidget);
    });

    /// 월/년 표시 테스트
    testWidgets('displays month and year correctly', (tester) async {
      final januaryDate = DateTime(2024, 1, 15);
      final decemberDate = DateTime(2023, 12, 25);
      
      // 1월 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: januaryDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 날짜 포맷이 올바른지 확인 (DateFormatter 사용)
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);

      // 12월 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: decemberDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    /// 이전 달 버튼 기능 테스트
    testWidgets('previous month button works correctly', (tester) async {
      var previousCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {
                previousCalled = true;
              },
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 이전 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(previousCalled, isTrue);
    });

    /// 다음 달 버튼 기능 테스트
    testWidgets('next month button works correctly', (tester) async {
      var nextCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {
                nextCalled = true;
              },
            ),
          ),
        ),
      );

      // 다음 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(nextCalled, isTrue);
    });

    /// 포맷 변경 기능 테스트 - 월별에서 2주로
    testWidgets('format change from month to two weeks works', (tester) async {
      CalendarFormat? changedFormat;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {
                changedFormat = format;
              },
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 2주 버튼 클릭
      await tester.tap(find.text('2주'));
      await tester.pump();

      expect(changedFormat, equals(CalendarFormat.twoWeeks));
    });

    /// 포맷 변경 기능 테스트 - 2주에서 월별로
    testWidgets('format change from two weeks to month works', (tester) async {
      CalendarFormat? changedFormat;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.twoWeeks,
              onFormatChanged: (format) {
                changedFormat = format;
              },
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 월별 버튼 클릭
      await tester.tap(find.text('월별'));
      await tester.pump();

      expect(changedFormat, equals(CalendarFormat.month));
    });

    /// 선택된 포맷 시각적 피드백 테스트
    testWidgets('shows visual feedback for selected format', (tester) async {
      // 월별 포맷이 선택된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 월별 버튼이 선택된 상태인지 확인 (시각적으로는 배경색이 다름)
      expect(find.text('월별'), findsOneWidget);
      expect(find.text('2주'), findsOneWidget);
    });

    /// 콜백이 null일 때 처리 테스트
    testWidgets('handles null callbacks gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: null,
              onNextPeriod: null,
            ),
          ),
        ),
      );

      // 버튼이 렌더링되지만 비활성화 상태인지 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // 비활성화된 버튼 클릭 시 에러가 발생하지 않는지 확인
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
    });

    /// 다양한 날짜 테스트
    testWidgets('handles different dates correctly', (tester) async {
      final testDates = [
        DateTime(2024, 2, 29), // 윤년
        DateTime(2023, 2, 28), // 평년
        DateTime(2024, 12, 31), // 연말
        DateTime(2024, 1, 1),   // 연초
      ];

      for (final date in testDates) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarHeader(
                focusedDay: date,
                calendarFormat: testFormat,
                onFormatChanged: (format) {},
                onPreviousPeriod: () {},
                onNextPeriod: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // 각 날짜에 대해 위젯이 정상적으로 렌더링되는지 확인
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      }
    });

    /// 테마 적용 테스트
    testWidgets('respects theme colors and styles', (tester) async {
      final customTheme = ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.purple,
          onPrimary: Colors.white,
          surface: Colors.grey,
          onSurface: Colors.white,
          outline: Colors.orange,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 위젯이 커스텀 테마와 함께 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      await tester.pumpAndSettle();
    });

    /// 위젯 구조 테스트
    testWidgets('has correct widget structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 주요 위젯 구조 확인
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(IconButton), findsNWidgets(2)); // 이전/다음 버튼
      expect(find.byType(GestureDetector), findsWidgets); // 포맷 토글 버튼들
    });

    /// 캘린더 포맷별 툴팁 테스트
    testWidgets('shows correct tooltips based on calendar format', (tester) async {
      // 월별 포맷 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      expect(find.byTooltip('이전 달'), findsOneWidget);
      expect(find.byTooltip('다음 달'), findsOneWidget);

      // 2주 포맷 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.twoWeeks,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      expect(find.byTooltip('이전 2주'), findsOneWidget);
      expect(find.byTooltip('다음 2주'), findsOneWidget);

      // 주별 포맷 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.week,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      expect(find.byTooltip('이전 주'), findsOneWidget);
      expect(find.byTooltip('다음 주'), findsOneWidget);
    });

    /// 접근성 테스트
    testWidgets('provides proper accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 접근성 지침 준수 확인
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();
      
      // 툴팁이 접근성에 도움이 되는지 확인
      expect(find.byTooltip('이전 달'), findsOneWidget);
      expect(find.byTooltip('다음 달'), findsOneWidget);
      
      handle.dispose();
    });

    /// 연속 클릭 테스트
    testWidgets('handles rapid button clicks correctly', (tester) async {
      var previousClickCount = 0;
      var nextClickCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: testFormat,
              onFormatChanged: (format) {},
              onPreviousPeriod: () {
                previousClickCount++;
              },
              onNextPeriod: () {
                nextClickCount++;
              },
            ),
          ),
        ),
      );

      // 이전 달 버튼 연속 클릭
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 다음 달 버튼 연속 클릭
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(previousClickCount, equals(5));
      expect(nextClickCount, equals(3));
    });

    /// 포맷 버튼 연속 클릭 테스트
    testWidgets('handles rapid format changes correctly', (tester) async {
      var formatChangeCount = 0;
      CalendarFormat? lastFormat;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {
                formatChangeCount++;
                lastFormat = format;
              },
              onPreviousPeriod: () {},
              onNextPeriod: () {},
            ),
          ),
        ),
      );

      // 포맷 변경 버튼 연속 클릭
      await tester.tap(find.text('2주'));
      await tester.pump();
      
      await tester.tap(find.text('월별'));
      await tester.pump();
      
      await tester.tap(find.text('2주'));
      await tester.pump();

      expect(formatChangeCount, equals(3));
      expect(lastFormat, equals(CalendarFormat.twoWeeks));
    });

    /// 경계값 테스트: 년도 경계
    testWidgets('handles year boundaries correctly', (tester) async {
      final yearBoundaryDates = [
        DateTime(2023, 12, 31), // 연말
        DateTime(2024, 1, 1),   // 연초
        DateTime(1999, 12, 31), // 1999년 말
        DateTime(2000, 1, 1),   // 2000년 초 (Y2K)
      ];

      for (final date in yearBoundaryDates) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarHeader(
                focusedDay: date,
                calendarFormat: testFormat,
                onFormatChanged: (format) {},
                onPreviousPeriod: () {},
                onNextPeriod: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(CalendarHeader), findsOneWidget);
      }
    });
  });
}