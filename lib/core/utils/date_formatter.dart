/// **Date Formatting Utility**
/// 
/// 로케일 초기화 오류를 방지하는 안전한 날짜 포맷팅 유틸리티입니다.

import 'package:intl/intl.dart';

class DateFormatter {
  /// 안전한 날짜 포맷팅 (로케일 오류 방지)
  static String format(DateTime date, String pattern, [String? locale]) {
    try {
      return DateFormat(pattern, locale).format(date);
    } catch (e) {
      // 로케일 초기화가 실패한 경우 기본 로케일 시도
      try {
        return DateFormat(pattern).format(date);
      } catch (e) {
        // 모든 포맷이 실패한 경우 기본 포맷 반환
        return _fallbackFormat(date, pattern);
      }
    }
  }

  /// 월/년 포맷팅
  static String formatMonthYear(DateTime date) {
    return format(date, 'yMMMM', 'ko_KR');
  }

  /// 월/일 (요일) 포맷팅
  static String formatMonthDayWeekday(DateTime date) {
    return format(date, 'M월 d일 (E)', 'ko_KR');
  }

  /// 월/일 (요일) 축약 포맷팅
  static String formatShortMonthDayWeekday(DateTime date) {
    return format(date, 'M/d (E)', 'ko_KR');
  }

  /// 시간 포맷팅
  static String formatTime(DateTime date) {
    return format(date, 'HH:mm', 'ko_KR');
  }

  /// 폴백 포맷팅 (DateFormat 실패 시)
  static String _fallbackFormat(DateTime date, String pattern) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    switch (pattern) {
      case 'yMMMM':
      case 'yMMMM ':
        return '${date.year}년 ${months[date.month - 1]}';
      case 'M월 d일 (E)':
        return '${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
      case 'M/d (E)':
        return '${date.month}/${date.day} (${weekdays[date.weekday % 7]})';
      case 'HH:mm':
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      default:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}