/// **캘린더 포맷별 네비게이션 세부 테스트**
/// 
/// 각 캘린더 포맷(월별/2주별/주별)에서의 네비게이션 동작을 상세 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';

void main() {
  group('Calendar Format Navigation Tests', () {
    late DateTime focusedDay;
    late List<String> navigationLog;

    setUp(() {
      focusedDay = DateTime(2024, 8, 15);
      navigationLog = [];
    });

    /// 캘린더 헤더 포맷별 툴팁 테스트
    group('Calendar Header Tooltip Tests', () {
      testWidgets('월별 포맷 툴팁 테스트', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarHeader(
                focusedDay: focusedDay,
                calendarFormat: CalendarFormat.month,
                onFormatChanged: (format) {},
                onPreviousPeriod: () => navigationLog.add('previous-month'),
                onNextPeriod: () => navigationLog.add('next-month'),
              ),
            ),
          ),
        );

        // 월별 포맷 툴팁 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);

        // 버튼 기능 테스트
        await tester.tap(find.byTooltip('이전 달'));
        await tester.pump();
        expect(navigationLog.contains('previous-month'), isTrue);

        await tester.tap(find.byTooltip('다음 달'));
        await tester.pump();
        expect(navigationLog.contains('next-month'), isTrue);
      });

      testWidgets('2주 포맷 툴팁 테스트', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarHeader(
                focusedDay: focusedDay,
                calendarFormat: CalendarFormat.twoWeeks,
                onFormatChanged: (format) {},
                onPreviousPeriod: () => navigationLog.add('previous-2weeks'),
                onNextPeriod: () => navigationLog.add('next-2weeks'),
              ),
            ),
          ),
        );

        // 2주 포맷 툴팁 확인
        expect(find.byTooltip('이전 2주'), findsOneWidget);
        expect(find.byTooltip('다음 2주'), findsOneWidget);
      });

      testWidgets('주별 포맷 툴팁 테스트', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarHeader(
                focusedDay: focusedDay,
                calendarFormat: CalendarFormat.week,
                onFormatChanged: (format) {},
                onPreviousPeriod: () => navigationLog.add('previous-week'),
                onNextPeriod: () => navigationLog.add('next-week'),
              ),
            ),
          ),
        );

        // 주별 포맷 툴팁 확인
        expect(find.byTooltip('이전 주'), findsOneWidget);
        expect(find.byTooltip('다음 주'), findsOneWidget);
      });
    });

    /// 네비게이션 로직 단위 테스트
    group('Navigation Logic Unit Tests', () {
      test('월별 네비게이션 날짜 계산', () {
        final baseDate = DateTime(2024, 8, 15);
        
        // 이전 달
        final previousMonth = DateTime(baseDate.year, baseDate.month - 1, 1);
        expect(previousMonth.year, equals(2024));
        expect(previousMonth.month, equals(7));
        expect(previousMonth.day, equals(1));
        
        // 다음 달
        final nextMonth = DateTime(baseDate.year, baseDate.month + 1, 1);
        expect(nextMonth.year, equals(2024));
        expect(nextMonth.month, equals(9));
        expect(nextMonth.day, equals(1));
      });

      test('2주 네비게이션 날짜 계산', () {
        final baseDate = DateTime(2024, 8, 15);
        
        // 이전 2주
        final previous2Weeks = baseDate.subtract(const Duration(days: 14));
        expect(previous2Weeks.year, equals(2024));
        expect(previous2Weeks.month, equals(8));
        expect(previous2Weeks.day, equals(1));
        
        // 다음 2주
        final next2Weeks = baseDate.add(const Duration(days: 14));
        expect(next2Weeks.year, equals(2024));
        expect(next2Weeks.month, equals(8));
        expect(next2Weeks.day, equals(29));
      });

      test('주별 네비게이션 날짜 계산', () {
        final baseDate = DateTime(2024, 8, 15);
        
        // 이전 주
        final previousWeek = baseDate.subtract(const Duration(days: 7));
        expect(previousWeek.year, equals(2024));
        expect(previousWeek.month, equals(8));
        expect(previousWeek.day, equals(8));
        
        // 다음 주
        final nextWeek = baseDate.add(const Duration(days: 7));
        expect(nextWeek.year, equals(2024));
        expect(nextWeek.month, equals(8));
        expect(nextWeek.day, equals(22));
      });

      test('연도 경계 처리 - 12월에서 1월로', () {
        final december = DateTime(2024, 12, 15);
        
        // 다음 달 (다음 해 1월)
        final nextMonth = DateTime(december.year, december.month + 1, 1);
        expect(nextMonth.year, equals(2025));
        expect(nextMonth.month, equals(1));
        expect(nextMonth.day, equals(1));
      });

      test('연도 경계 처리 - 1월에서 12월로', () {
        final january = DateTime(2024, 1, 15);
        
        // 이전 달 (이전 해 12월)
        final previousMonth = DateTime(january.year, january.month - 1, 1);
        expect(previousMonth.year, equals(2023));
        expect(previousMonth.month, equals(12));
        expect(previousMonth.day, equals(1));
      });

      test('윤년 2월 처리', () {
        final leapFeb = DateTime(2024, 2, 29);
        expect(leapFeb.month, equals(2));
        expect(leapFeb.day, equals(29));
        
        // 다음 달로 이동
        final march = DateTime(leapFeb.year, leapFeb.month + 1, 1);
        expect(march.month, equals(3));
        expect(march.day, equals(1));
      });
    });

    /// 성능 테스트
    group('Performance Tests', () {
      test('대량 날짜 계산 성능 테스트', () {
        final stopwatch = Stopwatch()..start();
        
        final baseDate = DateTime(2024, 8, 15);
        
        // 1000번의 날짜 계산
        for (int i = 0; i < 1000; i++) {
          // 월별 계산
          DateTime(baseDate.year, baseDate.month + i, 1);
          DateTime(baseDate.year, baseDate.month - i, 1);
          
          // 2주별 계산
          baseDate.add(Duration(days: 14 * i));
          baseDate.subtract(Duration(days: 14 * i));
        }
        
        stopwatch.stop();
        
        // 1초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}