/// **캘린더 화면**
/// 
/// Todo 항목들을 캘린더 형태로 표시하고 관리하는 화면입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../presentation/providers/todo_provider.dart';
import '../../core/utils/app_logger.dart';
import '../calendar/widgets/calendar_todo_list.dart';
import '../calendar/widgets/calendar_header.dart';

/// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 캘린더 포맷 Provider (월별/2주별 뷰)
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

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
  Map<DateTime, int> _getTodoCountsForMonth(List<TodoEntity> todos, DateTime month) {
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
    
    return todoCounts;
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);

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

        return Column(
          children: [
            // 캘린더 헤더
            CalendarHeader(
              focusedDay: _focusedDay,
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                ref.read(calendarFormatProvider.notifier).state = format;
              },
            ),
            
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
          AppLogger.debug('Calendar day selected: ${DateFormat('yyyy-MM-dd').format(selectedDay)}', tag: 'UI');
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
        
        // 헤더 스타일
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        
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
          // 마커 빌더 (Todo 개수 표시)
          markerBuilder: (context, day, events) {
            final count = todoCountsForMonth[DateTime(day.year, day.month, day.day)] ?? 0;
            if (count == 0) return null;
            
            return Positioned(
              bottom: 1,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
}