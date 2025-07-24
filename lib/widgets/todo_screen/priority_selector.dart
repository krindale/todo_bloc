import 'package:flutter/material.dart';

// 1. Priority Selector Widget
class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return Colors.red.shade400;
        case 'Medium':
          return Colors.blue.shade400;
        case 'Low':
          return Colors.green.shade400;
        default:
          return Colors.grey.shade400;
      }
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: getPriorityColor(selectedPriority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getPriorityColor(selectedPriority).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPriority,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onPriorityChanged(newValue);
            }
          },
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: getPriorityColor(selectedPriority),
            size: 16,
          ),
          style: TextStyle(
            color: getPriorityColor(selectedPriority),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          items: [
            DropdownMenuItem(
              value: 'High',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward, color: Colors.red.shade400, size: 16),
                  const SizedBox(width: 8),
                  const Text('High'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Medium',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove, color: Colors.blue.shade400, size: 16),
                  const SizedBox(width: 8),
                  const Text('Medium'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Low',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward, color: Colors.green.shade400, size: 16),
                  const SizedBox(width: 8),
                  const Text('Low'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}