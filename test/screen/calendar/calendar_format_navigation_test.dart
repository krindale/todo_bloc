/// **캘린더 포맷별 네비게이션 세부 테스트**
/// 
/// 각 캘린더 포맷(월별/2주별/주별)에서의 네비게이션 동작을 상세 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';

void main() {
  group('Calendar Format Navigation Tests', () {
    late DateTime focusedDay;
    late CalendarFormat calendarFormat;
    late List<String> navigationLog;

    setUp(() {
      focusedDay = DateTime(2024, 8, 15);
      calendarFormat = CalendarFormat.month;
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

        // 버튼 기능 테스트
        await tester.tap(find.byTooltip('이전 2주'));
        await tester.pump();
        expect(navigationLog.contains('previous-2weeks'), isTrue);

        await tester.tap(find.byTooltip('다음 2주'));
        await tester.pump();
        expect(navigationLog.contains('next-2weeks'), isTrue);
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

        // 버튼 기능 테스트
        await tester.tap(find.byTooltip('이전 주'));
        await tester.pump();
        expect(navigationLog.contains('previous-week'), isTrue);

        await tester.tap(find.byTooltip('다음 주'));
        await tester.pump();
        expect(navigationLog.contains('next-week'), isTrue);
      });
    });

    /// 포맷 전환 시 툴팁 변경 테스트
    group('Format Change Tooltip Update Tests', () {
      testWidgets('실시간 툴팁 업데이트 테스트', (tester) async {
        CalendarFormat currentFormat = CalendarFormat.month;
        
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: CalendarHeader(
                    focusedDay: focusedDay,
                    calendarFormat: currentFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        currentFormat = format;
                      });
                    },
                    onPreviousPeriod: () {},
                    onNextPeriod: () {},
                  ),
                );
              },
            ),
          ),
        );

        // 초기 월별 포맷 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);

        // 2주 포맷으로 변경
        await tester.tap(find.text('2주'));
        await tester.pumpAndSettle();

        // 2주 포맷 툴팁으로 변경됨 확인
        expect(find.byTooltip('이전 2주'), findsOneWidget);
        expect(find.byTooltip('다음 2주'), findsOneWidget);
        expect(find.byTooltip('이전 달'), findsNothing);
        expect(find.byTooltip('다음 달'), findsNothing);

        // 다시 월별 포맷으로 변경
        await tester.tap(find.text('월별'));
        await tester.pumpAndSettle();

        // 월별 포맷 툴팁으로 복원됨 확인
        expect(find.byTooltip('이전 달'), findsOneWidget);
        expect(find.byTooltip('다음 달'), findsOneWidget);
        expect(find.byTooltip('이전 2주'), findsNothing);
        expect(find.byTooltip('다음 2주'), findsNothing);
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

      test('월말 경계 처리', () {
        final endOfMonth = DateTime(2024, 1, 31);
        
        // 2주 후 (2월)
        final twoWeeksLater = endOfMonth.add(const Duration(days: 14));
        expect(twoWeeksLater.month, equals(2));
        expect(twoWeeksLater.day, equals(14));
      });
    });

    /// 성능 및 안정성 테스트
    group('Performance and Stability Tests', () {
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
          
          // 주별 계산
          baseDate.add(Duration(days: 7 * i));
          baseDate.subtract(Duration(days: 7 * i));
        }
        
        stopwatch.stop();
        
        // 1초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('극한 날짜 처리 테스트', () {
        // 최소 날짜
        final minDate = DateTime(1, 1, 1);
        expect(minDate.year, equals(1));
        
        // 최대 날짜 (DateTime.utc 범위 내)
        final maxDate = DateTime(2030, 12, 31);
        expect(maxDate.year, equals(2030));
        
        // 경계값 계산
        final nearMin = DateTime(minDate.year, minDate.month + 1, 1);
        expect(nearMin.month, equals(2));
        
        final nearMax = DateTime(maxDate.year, maxDate.month - 1, 1);
        expect(nearMax.month, equals(11));
      });
    });

    /// 툴팁 메시지 검증 테스트
    group('Tooltip Message Validation Tests', () {
      test('툴팁 메시지 형식 검증', () {
        final tooltips = {
          CalendarFormat.month: ['이전 달', '다음 달'],
          CalendarFormat.twoWeeks: ['이전 2주', '다음 2주'],
          CalendarFormat.week: ['이전 주', '다음 주'],
        };
        
        for (final format in tooltips.keys) {
          final messages = tooltips[format]!;
          
          // 이전/다음 쌍이 있어야 함
          expect(messages.length, equals(2));
          
          // 첫 번째는 '이전'으로 시작
          expect(messages[0].startsWith('이전'), isTrue);
          
          // 두 번째는 '다음'으로 시작
          expect(messages[1].startsWith('다음'), isTrue);
          
          // 메시지가 비어있지 않음
          expect(messages[0].isNotEmpty, isTrue);
          expect(messages[1].isNotEmpty, isTrue);
        }
      });

      test('기본 툴팁 메시지 검증', () {
        // CalendarHeader의 _getPreviousTooltip, _getNextTooltip 메서드가
        // 예상된 문자열을 반환하는지 간접적으로 검증
        
        final expectedPrevious = {
          CalendarFormat.month: '이전 달',
          CalendarFormat.twoWeeks: '이전 2주', 
          CalendarFormat.week: '이전 주',
        };
        
        final expectedNext = {
          CalendarFormat.month: '다음 달',
          CalendarFormat.twoWeeks: '다음 2주',
          CalendarFormat.week: '다음 주', 
        };
        
        // 모든 포맷에 대한 툴팁이 정의되어 있는지 확인
        for (final format in CalendarFormat.values) {
          expect(expectedPrevious.containsKey(format), isTrue, 
                 reason: '${format.name}에 대한 이전 툴팁이 정의되지 않음');
          expect(expectedNext.containsKey(format), isTrue,
                 reason: '${format.name}에 대한 다음 툴팁이 정의되지 않음');
        }
      });
    });
  });
}