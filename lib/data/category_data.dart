/// **카테고리 데이터 정의**
/// 
/// 할 일 항목의 카테고리 시스템을 위한 정적 데이터와 설정을 관리합니다.
/// 일관된 UI/UX와 시각적 식별을 위해 카테고리별 색상과 라벨을 정의합니다.
/// 
/// **포함된 카테고리:**
/// - Work: 업무 관련 작업 (인디고)
/// - Personal: 개인 생활 (그린)
/// - Shopping: 쇼핑 목록 (오렌지)
/// - Health: 건강 관리 (레드)
/// - Study: 학습 활동 (블루)
/// - Others: 기타 (그레이)
/// 
/// **디자인 시스템:**
/// - Material Design 3 색상 팔레트 기반
/// - 접근성 고려 (충분한 대비)
/// - 카테고리별 고유한 시각적 정체성
/// 
/// **사용 위치:**
/// - 할 일 추가/편집 시 카테고리 선택
/// - 통계 화면에서 카테고리별 분류
/// - 필터링 및 검색 기능
/// - 카테고리 칩 및 라벨 표시

import 'package:flutter/material.dart';

class CategoryData {
  final String label;
  final Color color;

  const CategoryData({
    required this.label,
    required this.color,
  });
}

class CategoryProvider {
  static const List<CategoryData> defaultCategories = [
    CategoryData(label: 'Work', color: Color(0xFF6366F1)),        // 세련된 인디고
    CategoryData(label: 'Personal', color: Color(0xFF8B5CF6)),    // 보라색 (개인)
    CategoryData(label: 'Shopping', color: Color(0xFFEC4899)),    // 핑크 (쇼핑)
    CategoryData(label: 'Health', color: Color(0xFF10B981)),      // 에메랄드 (건강)
    CategoryData(label: 'Finance', color: Color(0xFF3B82F6)),     // 파란색 (금융)
    CategoryData(label: 'Travel', color: Color(0xFFF59E0B)),      // 황금색 (여행)
    CategoryData(label: 'Family', color: Color(0xFFEF4444)),      // 빨간색 (가족)
    CategoryData(label: 'Social', color: Color(0xFF06B6D4)),      // 시안 (소셜)
  ];

  List<CategoryData> getCategories() {
    return defaultCategories;
  }
}