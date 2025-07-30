import 'package:flutter/material.dart';
import '../../model/todo_item.dart';

class AiGeneratorTodoList extends StatelessWidget {
  final List<TodoItem> todos;
  final Set<int> selectedTodos;
  final Function(int, bool) onTodoToggle;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const AiGeneratorTodoList({
    super.key,
    required this.todos,
    required this.selectedTodos,
    required this.onTodoToggle,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.checklist, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '생성된 할 일 목록',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Spacer(),
                Text(
                  '${selectedTodos.length}/${todos.length} 선택됨',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 할 일 목록
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: todos.asMap().entries.map((entry) {
                final index = entry.key;
                final todo = entry.value;
                final isSelected = selectedTodos.contains(index);

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width > 600
                      ? (MediaQuery.of(context).size.width - 80) / 2
                      : MediaQuery.of(context).size.width - 64,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => onTodoToggle(index, !isSelected),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  onTodoToggle(index, value ?? false);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(width: 40), // 체크박스 공간만큼 들여쓰기
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  todo.category ?? '일반',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                todo.priority,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 저장 및 다시 생성 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 저장 버튼
                ElevatedButton.icon(
                  onPressed: selectedTodos.isEmpty ? null : onSave,
                  icon: Icon(Icons.save),
                  label: Text('선택된 할 일 저장 (${selectedTodos.length}개)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 다시 생성 버튼
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: Icon(Icons.refresh),
                  label: Text('다시 생성하기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
