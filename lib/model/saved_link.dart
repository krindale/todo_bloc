/// **SavedLink 데이터 모델**
/// 
/// 사용자가 저장한 웹 링크의 데이터 구조를 정의합니다.
/// 북마크 기능과 웹뷰를 통한 링크 관리를 지원합니다.
/// 
/// **주요 속성:**
/// - title: 링크 제목 (메타데이터에서 자동 추출)
/// - url: 웹 주소
/// - category: 링크 카테고리
/// - userId: 사용자 ID (Firebase 동기화용)
/// - createdAt: 생성 시간
/// - id: 고유 식별자
/// 
/// **기술적 특징:**
/// - Hive 로컬 저장소 지원
/// - Firebase Firestore 동기화
/// - 웹뷰 통합으로 인앱 브라우징
/// - 카테고리별 자동 분류
/// 
/// **사용 사례:**
/// - 할 일과 관련된 참고 링크 저장
/// - 카테고리별 링크 북마크
/// - 오프라인에서도 링크 목록 접근

import 'package:hive/hive.dart';

part 'saved_link.g.dart';

@HiveType(typeId: 1)
class SavedLink extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String url;

  @HiveField(2)
  String category;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? firebaseDocId; // Firebase 문서 ID 추적용

  SavedLink({
    required this.title,
    required this.url,
    required this.category,
    required this.colorValue,
    required this.createdAt,
    this.firebaseDocId,
  });

  @override
  String toString() {
    return 'SavedLink{title: $title, url: $url, category: $category, colorValue: $colorValue, createdAt: $createdAt}';
  }
}