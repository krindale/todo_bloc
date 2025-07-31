/// **캘린더 헤더 위젯**
/// 
/// 캘린더 상단의 월/년 표시 및 뷰 전환 버튼을 제공합니다.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/utils/date_formatter.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final ValueChanged<CalendarFormat> onFormatChanged;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 월/년 표시
          Text(
            _formatMonthYear(focusedDay),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // 뷰 전환 버튼
          _buildFormatButton(context),
        ],
      ),
    );
  }

  /// 포맷 전환 버튼 구성
  Widget _buildFormatButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormatToggle(
            context: context,
            format: CalendarFormat.month,
            icon: Icons.calendar_view_month,
            label: '월별',
            isSelected: calendarFormat == CalendarFormat.month,
          ),
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          _buildFormatToggle(
            context: context,
            format: CalendarFormat.twoWeeks,
            icon: Icons.calendar_view_week,
            label: '2주',
            isSelected: calendarFormat == CalendarFormat.twoWeeks,
          ),
        ],
      ),
    );
  }

  /// 포맷 토글 버튼
  Widget _buildFormatToggle({
    required BuildContext context,
    required CalendarFormat format,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onFormatChanged(format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 월/년 포맷팅 (로케일 초기화 오류 방지)
  String _formatMonthYear(DateTime date) {
    return DateFormatter.formatMonthYear(date);
  }
}