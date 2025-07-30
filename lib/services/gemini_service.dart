/// **Gemini AI 서비스**
///
/// Google Gemini API를 활용하여 자연어 요청을 구체적인 할 일로 변환하는 서비스입니다.
/// 실제 AI 모델을 사용하여 더 정확하고 다양한 할 일을 생성할 수 있습니다.
///
/// **주요 기능:**
/// - Gemini Pro 모델을 통한 자연어 처리
/// - JSON 형태의 구조화된 응답 생성
/// - 토큰 제한 및 에러 처리
/// - 폴백 메커니즘 제공
///
/// **사용 예시:**
/// ```dart
/// final service = GeminiService();
/// final todos = await service.generateTodos("건강한 생활을 위한 계획을 세워줘");
/// ```

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/todo_item.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late GenerativeModel _model;
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // .env 파일에서 API 키 로드 시도
    String apiKey = '';
    try {
      await dotenv.load(fileName: ".env");
      apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isNotEmpty) {
        print('✅ .env에서 GEMINI_API_KEY 발견: ${apiKey.substring(0, 10)}...');
      }
    } catch (e) {
      print('경고: .env 파일을 읽을 수 없습니다: $e');
    }

    // .env에서 못 찾으면 시스템 환경 변수에서 시도
    if (apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
      if (apiKey.isNotEmpty) {
        print('✅ 시스템 환경변수에서 GEMINI_API_KEY 발견');
      }
    }

    if (apiKey.isEmpty) {
      print('경고: GEMINI_API_KEY가 설정되지 않았습니다. 폴백 모드로 실행됩니다.');
      print('- .env 파일에 GEMINI_API_KEY=your_key 설정하거나');
      print('- 시스템 환경 변수 GEMINI_API_KEY 설정해주세요');
      _isInitialized = true;
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      print('✅ Gemini 모델 초기화 완료');
    } catch (e) {
      print('❌ Gemini 모델 초기화 실패: $e');
      throw e;
    }

    _isInitialized = true;
  }

  /// 자연어 요청을 할 일 목록으로 변환
  Future<List<TodoItem>> generateTodos(String userRequest) async {
    if (!_isInitialized) {
      await initialize();
    }

    // API 키가 없으면 바로 폴백 사용
    String apiKey = '';
    try {
      apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    } catch (e) {
      // .env가 로드되지 않은 경우 시스템 환경 변수 시도
      apiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
    }

    if (apiKey.isEmpty) {
      return _generateFallbackTodos(userRequest);
    }

    try {
      print('🧠 Gemini API 호출 시작: $userRequest');
      final prompt = _buildPrompt(userRequest);
      final content = [Content.text(prompt)];

      print('📤 Gemini에 요청 전송 중...');
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        print('❌ Gemini API에서 빈 응답 받음');
        throw Exception('Gemini API에서 빈 응답을 받았습니다.');
      }

      print('📥 Gemini 응답 받음: ${response.text!.substring(0, 100)}...');
      final todos = _parseResponse(response.text!, userRequest);
      print('✅ 할 일 ${todos.length}개 생성 완료');
      return todos;
    } catch (e) {
      print('❌ Gemini API 호출 실패: $e');
      print('🔄 폴백 모드로 전환');
      // 폴백: 기본 템플릿 사용
      return _generateFallbackTodos(userRequest);
    }
  }

  /// 프롬프트 생성
  String _buildPrompt(String userRequest) {
    return '''
사용자 요청: "$userRequest"

위 요청을 바탕으로 **간결하고 실행 가능한** 할 일 목록을 생성해주세요.

📝 요구사항:
• 3-5개의 할 일 생성
• 각 할 일은 15-25자 내외로 간단명료하게 작성
• 구체적인 행동 중심으로 표현
• 불필요한 부가 설명 제외

카테고리: 건강, 학습, 업무, 생활, 재정, 일반
우선순위: High, Medium, Low
마감일: 1-30일 범위

JSON 형식으로만 응답:

{
  "todos": [
    {
      "title": "간결한 할 일 제목",
      "category": "카테고리",
      "priority": "우선순위",
      "dueDays": 숫자
    }
  ]
}

예시:
{
  "todos": [
    {
      "title": "매일 30분 산책하기",
      "category": "건강",
      "priority": "High",
      "dueDays": 1
    },
    {
      "title": "주간 운동 계획 세우기",
      "category": "건강",
      "priority": "Medium",
      "dueDays": 3
    }
  ]
}''';
  }

  /// Gemini 응답 파싱
  List<TodoItem> _parseResponse(String responseText, String originalRequest) {
    try {
      // JSON 부분만 추출 (마크다운 코드 블록 제거)
      String jsonText = responseText;
      if (jsonText.contains('```json')) {
        jsonText = jsonText.split('```json')[1].split('```')[0].trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.split('```')[1].split('```')[0].trim();
      }

      final Map<String, dynamic> data = jsonDecode(jsonText);
      final List<dynamic> todosJson = data['todos'] ?? [];

      final todos = <TodoItem>[];
      final now = DateTime.now();

      for (final todoJson in todosJson) {
        if (todoJson is Map<String, dynamic>) {
          final title = todoJson['title']?.toString() ?? '';
          final category = todoJson['category']?.toString() ?? '일반';
          final priority = todoJson['priority']?.toString() ?? 'Medium';
          final dueDays = (todoJson['dueDays'] as num?)?.toInt() ?? 7;

          if (title.isNotEmpty) {
            todos.add(TodoItem(
              title: title,
              category: category,
              priority: priority,
              dueDate: now.add(Duration(days: dueDays)),
            ));
          }
        }
      }

      return todos.isEmpty ? _generateFallbackTodos(originalRequest) : todos;
    } catch (e) {
      print('Gemini 응답 파싱 실패: $e');
      print('응답 내용: $responseText');
      return _generateFallbackTodos(originalRequest);
    }
  }

  /// 폴백 할 일 생성 (Gemini 실패 시)
  List<TodoItem> _generateFallbackTodos(String request) {
    final now = DateTime.now();
    final normalizedRequest = request.toLowerCase();

    // 간단한 키워드 기반 분류
    String category = '일반';
    List<TodoItem> fallbackTodos = [];

    if (_containsKeywords(normalizedRequest, ['건강', '운동', '다이어트'])) {
      category = '건강';
      fallbackTodos = [
        TodoItem(
          title: '매일 30분 운동하기',
          category: category,
          priority: 'High',
          dueDate: now.add(Duration(days: 1)),
        ),
        TodoItem(
          title: '건강한 식단 계획하기',
          category: category,
          priority: 'Medium',
          dueDate: now.add(Duration(days: 3)),
        ),
      ];
    } else if (_containsKeywords(normalizedRequest, ['공부', '학습', '책'])) {
      category = '학습';
      fallbackTodos = [
        TodoItem(
          title: '매일 1시간 공부하기',
          category: category,
          priority: 'High',
          dueDate: now.add(Duration(days: 1)),
        ),
        TodoItem(
          title: '학습 계획 세우기',
          category: category,
          priority: 'Medium',
          dueDate: now.add(Duration(days: 2)),
        ),
      ];
    } else {
      // 일반적인 목표
      fallbackTodos = [
        TodoItem(
          title: '$request 관련 정보 조사하기',
          category: '일반',
          priority: 'Medium',
          dueDate: now.add(Duration(days: 2)),
        ),
        TodoItem(
          title: '$request 실행 계획 세우기',
          category: '일반',
          priority: 'High',
          dueDate: now.add(Duration(days: 3)),
        ),
        TodoItem(
          title: '$request 첫 번째 단계 실행하기',
          category: '일반',
          priority: 'High',
          dueDate: now.add(Duration(days: 5)),
        ),
      ];
    }

    return fallbackTodos;
  }

  /// 키워드 포함 여부 확인
  bool _containsKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// API 사용량 확인 (선택적)
  Future<Map<String, dynamic>> getUsageInfo() async {
    // Gemini API는 현재 사용량 조회 API가 제한적이므로
    // 로컬에서 호출 횟수를 추적하거나 다른 방법을 사용
    return {
      'status': 'active',
      'model': 'gemini-1.5-flash',
      'initialized': _isInitialized,
    };
  }
}
