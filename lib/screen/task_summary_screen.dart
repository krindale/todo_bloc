import 'package:flutter/material.dart';

/// 작업 요약을 보여주는 화면 위젯
/// 전체 작업 현황, 카테고리 및 진행률을 표시합니다.
class TaskSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 작업 통계 카드
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Task Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  // 작업 현황 요약 (전체, 완료, 대기, 오늘 마감)
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
          
          // 작업 카테고리 섹션
          Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // 카테고리 칩 목록
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
          
          // 작업 진행률 카드
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
                        Text('18개 중 14개 완료', style: TextStyle(fontSize: 16)),
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

  /// 작업 정보를 표시하는 위젯을 생성합니다.
  /// [value]: 표시할 숫자 값
  /// [label]: 설명 레이블
  /// [color]: 숫자의 색상
  Widget taskInfo(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  /// 카테고리 칩 위젯을 생성합니다.
  /// [label]: 카테고리 이름
  /// [color]: 칩의 배경색
  Widget categoryChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
