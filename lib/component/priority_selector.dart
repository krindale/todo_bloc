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
    return Align(
      alignment: Alignment.centerLeft,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(12),
        isSelected: ['High', 'Medium', 'Low']
            .map((e) => e == selectedPriority)
            .toList(),
        onPressed: (int index) {
          onPriorityChanged(['High', 'Medium', 'Low'][index]);
        },
        constraints: const BoxConstraints(
          minHeight: 30.0,
          minWidth: 60.0,
        ),
        children: const [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text('High')),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text('Medium')),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text('Low')),
        ],
      ),
    );
  }
}