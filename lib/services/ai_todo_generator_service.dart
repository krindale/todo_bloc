/// **AI 할 일 생성 서비스**
/// 
/// 사용자의 추상적인 요청을 받아 구체적인 할 일 목록으로 변환하는 AI 서비스입니다.
/// 예: "건강을 위한 플랜을 짜줘" → ["매일 30분 운동하기", "하루 2L 물 마시기", ...]
/// 
/// **주요 기능:**
/// - 자연어 입력을 구조화된 할 일로 변환
/// - 카테고리별 할 일 생성 (건강, 학습, 업무 등)
/// - 우선순위 및 기간 설정 제안
/// - 실행 가능한 세부 단계로 분해
/// 
/// **사용 예시:**
/// ```dart
/// final service = AiTodoGeneratorService();
/// final todos = await service.generateTodos("건강한 생활 습관 만들기");
/// ```

import 'dart:convert';
import 'dart:math';
import '../model/todo_item.dart';

class AiTodoGeneratorService {
  static final AiTodoGeneratorService _instance = AiTodoGeneratorService._internal();
  factory AiTodoGeneratorService() => _instance;
  AiTodoGeneratorService._internal();

  /// 추상적인 요청을 구체적인 할 일 목록으로 변환
  Future<List<TodoItem>> generateTodos(String abstractRequest) async {
    // TODO: 실제 AI API 연동 (OpenAI, Gemini 등)
    // 현재는 미리 정의된 템플릿으로 구현
    
    await Future.delayed(Duration(seconds: 1)); // API 호출 시뮬레이션
    
    final normalizedRequest = abstractRequest.toLowerCase().trim();
    
    // 카테고리별 템플릿 매칭 - 더 구체적인 키워드 우선
    if (_isFinanceRelated(normalizedRequest)) {
      return _generateFinanceTodos();
    } else if (_isHealthRelated(normalizedRequest)) {
      return _generateHealthTodos();
    } else if (_isStudyRelated(normalizedRequest)) {
      return _generateStudyTodos();
    } else if (_isWorkRelated(normalizedRequest)) {
      return _generateWorkTodos();
    } else if (_isLifestyleRelated(normalizedRequest)) {
      return _generateLifestyleTodos();
    } else {
      return _generateGeneralTodos(abstractRequest);
    }
  }

  /// 건강 관련 키워드 체크
  bool _isHealthRelated(String request) {
    final healthKeywords = [
      '건강', '운동', '다이어트', '식단', '체중', '헬스', '요가', '러닝', 
      '조깅', '근육', '스트레칭', '명상', '수면', '금연', '금주', '물'
    ];
    return healthKeywords.any((keyword) => request.contains(keyword));
  }

  /// 학습 관련 키워드 체크
  bool _isStudyRelated(String request) {
    final studyKeywords = [
      '공부', '학습', '자격증', '시험', '토익', '영어', '독서', '책', 
      '강의', '코딩', '프로그래밍', '개발', '스킬', '언어', '수학'
    ];
    return studyKeywords.any((keyword) => request.contains(keyword));
  }

  /// 업무 관련 키워드 체크
  bool _isWorkRelated(String request) {
    final workKeywords = [
      '업무', '일', '프로젝트', '회의', '발표', '보고서', '기획', 
      '마케팅', '영업', '분석', '개발', '설계', '테스트'
    ];
    return workKeywords.any((keyword) => request.contains(keyword));
  }

  /// 라이프스타일 관련 키워드 체크
  bool _isLifestyleRelated(String request) {
    final lifestyleKeywords = [
      '집', '정리', '청소', '요리', '취미', '여행', '가족', '친구',
      '소통', '휴식', '여가', '문화', '예술', '음악'
    ];
    return lifestyleKeywords.any((keyword) => request.contains(keyword));
  }

  /// 재정 관리 관련 키워드 체크
  bool _isFinanceRelated(String request) {
    final financeKeywords = [
      '돈', '저축', '투자', '가계부', '예산', '용돈', '경제', 
      '주식', '부동산', '보험', '연금', '대출', '카드', '가계', '재정'
    ];
    return financeKeywords.any((keyword) => request.contains(keyword));
  }

  /// 건강 관련 할 일 생성
  List<TodoItem> _generateHealthTodos() {
    final now = DateTime.now();
    final healthTodos = [
      TodoItem(
        title: '매일 30분 이상 운동하기 (걷기, 조깅, 홈트레이닝 등)',
        category: '건강',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '하루 2L 이상 물 마시기 (텀블러 준비하고 시간대별로)',
        category: '건강',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '규칙적인 수면 패턴 만들기 (같은 시간에 잠자리)',
        category: '건강',
        priority: 'High',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '금연/금주 실천하기 (점진적으로 줄이고 대체 활동)',
        category: '건강',
        priority: 'High',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '건강한 식단 계획하기 (주간 식단표 작성)',
        category: '건강',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '스트레칭 루틴 만들기 (아침/저녁 10분씩)',
        category: '건강',
        priority: 'Low',
        dueDate: now.add(Duration(days: 2)),
      ),
    ];
    
    // 랜덤하게 4-6개 선택
    healthTodos.shuffle();
    return List<TodoItem>.from(healthTodos.take(Random().nextInt(3) + 4));
  }

  /// 학습 관련 할 일 생성
  List<TodoItem> _generateStudyTodos() {
    final now = DateTime.now();
    final studyTodos = [
      TodoItem(
        title: '매일 1시간 집중 학습하기 (포모도로 기법 활용)',
        category: '학습',
        priority: 'High',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '온라인 강의 수강하기 (관심 분야 강의 찾기)',
        category: '학습',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '매주 책 1권 읽기 (독서 목록 작성하고 독후감)',
        category: '학습',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '영어 공부 30분씩 하기 (단어암기, 리스닝)',
        category: '학습',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '새로운 기술/도구 배우기 (업무 관련 스킬)',
        category: '학습',
        priority: 'Low',
        dueDate: now.add(Duration(days: 14)),
      ),
      TodoItem(
        title: '학습 노트 정리하기 (체계적으로 정리하고 복습)',
        category: '학습',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
    ];
    
    studyTodos.shuffle();
    return List<TodoItem>.from(studyTodos.take(Random().nextInt(3) + 4));
  }

  /// 업무 관련 할 일 생성
  List<TodoItem> _generateWorkTodos() {
    final now = DateTime.now();
    final workTodos = [
      TodoItem(
        title: '업무 우선순위 정리하기 (중요도와 긴급도 분류)',
        category: '업무',
        priority: 'High',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '프로젝트 진행상황 점검하기 (마일스톤 확인)',
        category: '업무',
        priority: 'High',
        dueDate: now.add(Duration(days: 2)),
      ),
      TodoItem(
        title: '팀 미팅 준비하기 (안건 정리하고 자료 준비)',
        category: '업무',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '업무 자동화 방안 검토하기 (반복 작업 도구 찾기)',
        category: '업무',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '동료와 소통 시간 만들기 (협업 효율성 향상)',
        category: '업무',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 2)),
      ),
      TodoItem(
        title: '업무 역량 강화 계획 세우기 (스킬 파악하고 학습)',
        category: '업무',
        priority: 'Low',
        dueDate: now.add(Duration(days: 14)),
      ),
    ];
    
    workTodos.shuffle();
    return List<TodoItem>.from(workTodos.take(Random().nextInt(3) + 4));
  }

  /// 라이프스타일 관련 할 일 생성
  List<TodoItem> _generateLifestyleTodos() {
    final now = DateTime.now();
    final lifestyleTodos = [
      TodoItem(
        title: '집 정리정돈하기 (불필요한 물건 정리하고 공간 최적화)',
        category: '생활',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '새로운 요리 도전하기 (매주 새로운 레시피)',
        category: '생활',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '가족/친구와 소통 시간 늘리기 (정기적인 만남)',
        category: '생활',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 2)),
      ),
      TodoItem(
        title: '취미 활동 시간 확보하기 (스트레스 해소 위한 여가)',
        category: '생활',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '디지털 디톡스 실천하기 (스마트폰 사용 시간 줄이기)',
        category: '생활',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '자기 계발 시간 만들기 (명상, 일기쓰기, 성찰)',
        category: '생활',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
    ];
    
    lifestyleTodos.shuffle();
    return List<TodoItem>.from(lifestyleTodos.take(Random().nextInt(3) + 4));
  }

  /// 재정 관리 관련 할 일 생성
  List<TodoItem> _generateFinanceTodos() {
    final now = DateTime.now();
    final financeTodos = [
      TodoItem(
        title: '가계부 작성하기 (수입과 지출 내역 상세히 기록)',
        category: '재정',
        priority: 'High',
        dueDate: now.add(Duration(days: 1)),
      ),
      TodoItem(
        title: '월 예산 계획 세우기 (필수/선택 지출 구분)',
        category: '재정',
        priority: 'High',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '비상금 마련하기 (월 소득3-6개월치 목표)',
        category: '재정',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 7)),
      ),
      TodoItem(
        title: '투자 공부하고 시작하기 (안전한 상품부터)',
        category: '재정',
        priority: 'Low',
        dueDate: now.add(Duration(days: 30)),
      ),
      TodoItem(
        title: '불필요한 구독 서비스 정리하기 (멤버십 해지)',
        category: '재정',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 2)),
      ),
      TodoItem(
        title: '재정 목표 설정하기 (단기/중기/장기 계획)',
        category: '재정',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 7)),
      ),
    ];
    
    financeTodos.shuffle();
    return List<TodoItem>.from(financeTodos.take(Random().nextInt(2) + 4));
  }

  /// 일반적인 할 일 생성 (키워드 매칭되지 않는 경우)
  List<TodoItem> _generateGeneralTodos(String request) {
    final now = DateTime.now();
    final generalTodos = [
      TodoItem(
        title: '$request 관련 정보 조사하기 (온라인 검색, 전문가 의견)',
        category: '일반',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 2)),
      ),
      TodoItem(
        title: '$request 계획 세우기 (구체적인 실행 계획과 일정)',
        category: '일반',
        priority: 'High',
        dueDate: now.add(Duration(days: 3)),
      ),
      TodoItem(
        title: '$request 첫 번째 단계 실행하기 (작은 것부터 시작)',
        category: '일반',
        priority: 'High',
        dueDate: now.add(Duration(days: 5)),
      ),
      TodoItem(
        title: '$request 관련 도구/자료 준비하기 (필요한 준비물 확보)',
        category: '일반',
        priority: 'Medium',
        dueDate: now.add(Duration(days: 4)),
      ),
      TodoItem(
        title: '$request 진행상황 점검하기 (정기적 목표 달성도 확인)',
        category: '일반',
        priority: 'Low',
        dueDate: now.add(Duration(days: 7)),
      ),
    ];
    
    return generalTodos;
  }

  /// 미리 정의된 추천 요청 목록
  List<String> getSuggestedRequests() {
    return [
      '건강한 생활 습관 만들기',
      '새로운 기술 학습하기', 
      '업무 효율성 높이기',
      '집 정리하고 깔끔하게 만들기',
      '가계 관리하고 저축하기',
      '새로운 취미 시작하기',
      '인간관계 개선하기',
      '스트레스 관리하기',
      '시간 관리 잘하기',
      '자기계발하기',
    ];
  }
}