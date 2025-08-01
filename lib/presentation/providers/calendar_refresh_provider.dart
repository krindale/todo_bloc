/// **캘린더 새로고침 Provider**
/// 
/// 캘린더 데이터를 수동으로 새로고침할 수 있는 기능을 제공합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'combined_todo_provider.dart';
import 'todo_provider.dart';

/// 캘린더 새로고침 Provider
final calendarRefreshProvider = StateNotifierProvider<CalendarRefreshNotifier, int>((ref) {
  return CalendarRefreshNotifier(ref);
});

/// 캘린더 새로고침 상태 관리
class CalendarRefreshNotifier extends StateNotifier<int> {
  final Ref _ref;

  CalendarRefreshNotifier(this._ref) : super(0);

  /// 캘린더 데이터를 수동으로 새로고침
  void refreshCalendar() {
    // Combined provider를 무효화하여 새로고침
    _ref.invalidate(combinedTodoProvider);
    _ref.invalidate(hiveTodoListProvider);
    _ref.invalidate(todoListProvider);
    
    // 상태 업데이트 (UI에 변경 알림)
    state = state + 1;
  }

  /// 할 일 추가 후 자동 새로고침
  void refreshAfterAdd() {
    refreshCalendar();
  }

  /// 할 일 수정 후 자동 새로고침
  void refreshAfterUpdate() {
    refreshCalendar();
  }

  /// 할 일 삭제 후 자동 새로고침
  void refreshAfterDelete() {
    refreshCalendar();
  }
}