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
  final VoidCallback? onPreviousPeriod;
  final VoidCallback? onNextPeriod;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
    this.onPreviousPeriod,
    this.onNextPeriod,
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
          // 이전/다음 기간 버튼과 월/년 표시
          Row(
            children: [
              // 이전 기간 버튼
              IconButton(
                onPressed: onPreviousPeriod,
                icon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: _getPreviousTooltip(),
              ),
              // 월/년 표시
              Text(
                _formatMonthYear(focusedDay),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              // 다음 기간 버튼
              IconButton(
                onPressed: onNextPeriod,
                icon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: _getNextTooltip(),
              ),
            ],
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

  /// 이전 버튼 툴팁 반환
  String _getPreviousTooltip() {
    switch (calendarFormat) {
      case CalendarFormat.month:
        return '이전 달';
      case CalendarFormat.twoWeeks:
        return '이전 2주';
      case CalendarFormat.week:
        return '이전 주';
      default:
        return '이전 기간';
    }
  }

  /// 다음 버튼 툴팁 반환
  String _getNextTooltip() {
    switch (calendarFormat) {
      case CalendarFormat.month:
        return '다음 달';
      case CalendarFormat.twoWeeks:
        return '다음 2주';
      case CalendarFormat.week:
        return '다음 주';
      default:
        return '다음 기간';
    }
  }
}
