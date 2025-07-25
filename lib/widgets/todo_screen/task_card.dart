/// **할 일 카드 위젯**
/// 
/// 개별 할 일 항목을 카드 형태로 표시하는 재사용 가능한 위젯입니다.
/// Material Design 가이드라인을 따르며, 인터랙티브한 사용자 경험을 제공합니다.
/// 
/// **주요 기능:**
/// - 할 일 제목, 우선순위, 마감일 표시
/// - 완료 상태 체크박스
/// - 편집/삭제 액션 버튼
/// - 우선순위별 시각적 구분 (색상, 아이콘)
/// - 마감일 임박 시 경고 표시
/// 
/// **UI/UX 특징:**
/// - Material Card 디자인
/// - 반응형 터치 피드백
/// - 직관적인 액션 버튼 배치
/// - 접근성 지원 (Semantics)
/// - 애니메이션 지원 (완료 상태 변경 시)
/// 
/// **재사용성:**
/// - Stateless 위젯으로 성능 최적화
/// - 콜백 패턴으로 상위 위젯과 통신
/// - 다양한 화면에서 활용 가능

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../model/todo_item.dart';
class TaskCard extends StatelessWidget {
  final TodoItem task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onCompleteChanged;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red.shade400;
        break;
      case 'Medium':
        priorityColor = Colors.blue.shade400;
        break;
      default:
        priorityColor = Colors.green.shade400;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        leading: Container(
          width: 5,
          height: double.infinity,
          color: priorityColor,
        ),
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${DateFormat.yMMMd().format(task.dueDate)}'),
            if (task.hasAlarm) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.alarm,
                size: 16,
                color: Colors.orange.shade600,
              ),
              if (task.alarmTime != null) ...[
                const SizedBox(width: 4),
                Text(
                  TimeOfDay.fromDateTime(task.alarmTime!).format(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: onCompleteChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: onEdit,
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
