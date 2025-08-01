/// **캘린더 화면**
///
/// Todo 항목들을 캘린더 형태로 표시하고 관리하는 화면입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../presentation/providers/combined_todo_provider.dart';
import '../../presentation/providers/calendar_refresh_provider.dart';
import '../../core/utils/app_logger.dart';
import '../calendar/widgets/calendar_todo_list.dart';
import '../calendar/widgets/calendar_header.dart';

/// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 캘린더 포맷 Provider (월별/2주별 뷰)
final calendarFormatProvider =
    StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

/// 캘린더 화면
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    AppLogger.info('CalendarScreen initialized', tag: 'UI');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 특정 날짜의 Todo 항목들 가져오기
  List<TodoEntity> _getTodosForDay(List<TodoEntity> todos, DateTime day) {
    return todos.where((todo) {
      final todoDate = DateTime(
        todo.dueDate.year,
        todo.dueDate.month,
        todo.dueDate.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return todoDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// 날짜별 Todo 개수 맵 생성
  Map<DateTime, int> _getTodoCountsForMonth(
      List<TodoEntity> todos, DateTime month) {
    final Map<DateTime, int> todoCounts = {};

    for (final todo in todos) {
      final todoDate = DateTime(
        todo.dueDate.year,
        todo.dueDate.month,
        todo.dueDate.day,
      );

      // 해당 월의 Todo만 포함
      if (todoDate.month == month.month && todoDate.year == month.year) {
        todoCounts[todoDate] = (todoCounts[todoDate] ?? 0) + 1;
      }
    }

    AppLogger.debug(
        'Todo counts for ${DateFormat('yyyy-MM').format(month)}: ${todoCounts.length} days with todos',
        tag: 'Calendar');
    return todoCounts;
  }

  /// 이전 기간으로 이동 (캘린더 포맷에 따라)
  void _goToPreviousPeriod() {
    final calendarFormat = ref.read(calendarFormatProvider);
    setState(() {
      switch (calendarFormat) {
        case CalendarFormat.month:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
          AppLogger.debug(
              'Calendar moved to previous month: ${DateFormat('yyyy-MM').format(_focusedDay)}',
              tag: 'UI');
          break;
        case CalendarFormat.twoWeeks:
          _focusedDay = _focusedDay.subtract(const Duration(days: 14));
          AppLogger.debug(
              'Calendar moved to previous 2 weeks: ${DateFormat('yyyy-MM-dd').format(_focusedDay)}',
              tag: 'UI');
          break;
        case CalendarFormat.week:
          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
          AppLogger.debug(
              'Calendar moved to previous week: ${DateFormat('yyyy-MM-dd').format(_focusedDay)}',
              tag: 'UI');
          break;
      }
    });
  }

  /// 다음 기간으로 이동 (캘린더 포맷에 따라)
  void _goToNextPeriod() {
    final calendarFormat = ref.read(calendarFormatProvider);
    setState(() {
      switch (calendarFormat) {
        case CalendarFormat.month:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
          AppLogger.debug(
              'Calendar moved to next month: ${DateFormat('yyyy-MM').format(_focusedDay)}',
              tag: 'UI');
          break;
        case CalendarFormat.twoWeeks:
          _focusedDay = _focusedDay.add(const Duration(days: 14));
          AppLogger.debug(
              'Calendar moved to next 2 weeks: ${DateFormat('yyyy-MM-dd').format(_focusedDay)}',
              tag: 'UI');
          break;
        case CalendarFormat.week:
          _focusedDay = _focusedDay.add(const Duration(days: 7));
          AppLogger.debug(
              'Calendar moved to next week: ${DateFormat('yyyy-MM-dd').format(_focusedDay)}',
              tag: 'UI');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(combinedTodoProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);

    // 새로고침 상태 watch (UI 갱신 트리거용)
    ref.watch(calendarRefreshProvider);

    return todosAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        AppLogger.error('Error loading todos for calendar',
            tag: 'UI', error: error, stackTrace: stackTrace);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '캘린더를 불러오는 중 오류가 발생했습니다.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      data: (todos) {
        final todosForSelectedDay = _getTodosForDay(todos, selectedDate);
        final todoCountsForMonth = _getTodoCountsForMonth(todos, _focusedDay);

        return Scaffold(
          body: Column(
            children: [
              // 캘린더 헤더
              CalendarHeader(
                focusedDay: _focusedDay,
                calendarFormat: calendarFormat,
                onFormatChanged: (format) {
                  ref.read(calendarFormatProvider.notifier).state = format;
                },
                onPreviousPeriod: _goToPreviousPeriod,
                onNextPeriod: _goToNextPeriod,
              ),

              const SizedBox(height: 8),

              // 캘린더
              _buildCalendar(
                todos: todos,
                selectedDate: selectedDate,
                calendarFormat: calendarFormat,
                todoCountsForMonth: todoCountsForMonth,
              ),

              const SizedBox(height: 8),

              // 선택된 날짜의 Todo 목록
              Expanded(
                child: CalendarTodoList(
                  selectedDate: selectedDate,
                  todos: todosForSelectedDay,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 캘린더 새로고침
              ref.read(calendarRefreshProvider.notifier).refreshCalendar();
              AppLogger.info('Calendar manually refreshed', tag: 'UI');
            },
            tooltip: '캘린더 새로고침',
            mini: true,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  /// 캘린더 위젯 구성
  Widget _buildCalendar({
    required List<TodoEntity> todos,
    required DateTime selectedDate,
    required CalendarFormat calendarFormat,
    required Map<DateTime, int> todoCountsForMonth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<TodoEntity>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: calendarFormat,

        // 날짜 선택
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).state = selectedDay;
          setState(() {
            _focusedDay = focusedDay;
          });
          AppLogger.debug(
              'Calendar day selected: ${DateFormat('yyyy-MM-dd').format(selectedDay)}',
              tag: 'UI');
        },

        // 페이지 변경
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },

        // 이벤트 로더 (해당 날짜의 Todo 개수)
        eventLoader: (day) => _getTodosForDay(todos, day),

        // 캘린더 스타일
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
          holidayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
          ),

          // 선택된 날짜 스타일
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),

          // 오늘 날짜 스타일
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),

          // 마커 스타일 (Todo 개수 표시)
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          markerSize: 6,
        ),

        // 헤더 스타일 (헤더 완전히 숨김)
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.zero, // 패딩 제거
          headerMargin: EdgeInsets.zero, // 마진 제거
          titleTextStyle: const TextStyle(
            fontSize: 0, // 폰트 크기를 0으로 설정하여 텍스트 숨김
            height: 0, // 라인 높이를 0으로 설정
          ),
        ),
        headerVisible: false, // 헤더 자체를 숨김

        // 요일 스타일
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
          weekdayStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 캘린더 빌더
        calendarBuilders: CalendarBuilders(
          // 마커 빌더 (Todo 개수를 점으로 표시)
          markerBuilder: (context, day, events) {
            final count =
                todoCountsForMonth[DateTime(day.year, day.month, day.day)] ?? 0;
            if (count == 0) return null;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  count > 3 ? 3 : count, // 최대 3개의 점만 표시
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getTaskPriorityColor(context, todos, day, index),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 태스크 우선순위에 따른 색상 반환
  Color _getTaskPriorityColor(
      BuildContext context, List<TodoEntity> todos, DateTime day, int index) {
    final todosForDay = _getTodosForDay(todos, day);

    if (index >= todosForDay.length) {
      return Theme.of(context).colorScheme.secondary;
    }

    final todo = todosForDay[index];
    switch (todo.priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.low:
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
