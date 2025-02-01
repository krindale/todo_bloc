import 'package:flutter/material.dart';

class TaskSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Task Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      taskInfo('32', 'Total Tasks', Colors.blue),
                      taskInfo('18', 'Completed', Colors.green),
                      taskInfo('8', 'Pending', Colors.purple),
                      taskInfo('6', 'Due Today', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: [
              categoryChip('Work', Colors.purple),
              categoryChip('Personal', Colors.grey),
              categoryChip('Shopping', Colors.blueGrey),
              categoryChip('Health', Colors.green),
              categoryChip('Finance', Colors.blue),
              categoryChip('Travel', Colors.orange),
              categoryChip('Family', Colors.brown),
              categoryChip('Social', Colors.cyan),
            ],
          ),
          SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Task Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text('78%', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
                        SizedBox(height: 5),
                        Text('14 of 18 tasks completed', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget taskInfo(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget categoryChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
