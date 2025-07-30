/// **테스트 헬퍼 유틸리티**
///
/// 테스트 코드에서 공통으로 사용되는 헬퍼 함수들과 
/// 목 데이터 생성 함수들을 제공합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/model/todo_item.dart';
import '../../lib/core/constants/app_constants.dart';

/// **테스트용 TodoItem 생성 헬퍼**
class TodoItemTestHelper {
  TodoItemTestHelper._();
  
  /// 기본 테스트 할 일 생성
  static TodoItem createTestTodo({
    String? title,
    String? category,
    String? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool isCompleted = false,
  }) {
    return TodoItem(
      title: title ?? 'Test Todo',
      category: category ?? CategoryConstants.general,
      priority: priority ?? PriorityConstants.medium,
      createdAt: createdAt ?? DateTime.now(),
      dueDate: dueDate,
      isCompleted: isCompleted,
    );
  }
  
  /// 여러 개의 테스트 할 일 생성
  static List<TodoItem> createTestTodos(int count) {
    return List.generate(count, (index) => createTestTodo(
      title: 'Test Todo ${index + 1}',
      category: _getRandomCategory(index),
      priority: _getRandomPriority(index),
    ));
  }
  
  /// 카테고리별 테스트 할 일 생성
  static List<TodoItem> createTestTodosByCategory(String category, int count) {
    return List.generate(count, (index) => createTestTodo(
      title: '$category Todo ${index + 1}',
      category: category,
    ));
  }
  
  /// 우선순위별 테스트 할 일 생성
  static List<TodoItem> createTestTodosByPriority(String priority, int count) {
    return List.generate(count, (index) => createTestTodo(
      title: '$priority Priority Todo ${index + 1}',
      priority: priority,
    ));
  }
  
  /// 완료된 테스트 할 일 생성
  static List<TodoItem> createCompletedTestTodos(int count) {
    return List.generate(count, (index) => createTestTodo(
      title: 'Completed Todo ${index + 1}',
      isCompleted: true,
    ));
  }
  
  /// 기한이 지난 테스트 할 일 생성
  static List<TodoItem> createOverdueTestTodos(int count) {
    return List.generate(count, (index) => createTestTodo(
      title: 'Overdue Todo ${index + 1}',
      dueDate: DateTime.now().subtract(Duration(days: index + 1)),
    ));
  }
  
  static String _getRandomCategory(int index) {
    final categories = CategoryConstants.defaultCategories;
    return categories[index % categories.length];
  }
  
  static String _getRandomPriority(int index) {
    final priorities = PriorityConstants.allPriorities;
    return priorities[index % priorities.length];
  }
}

/// **위젯 테스트 헬퍼**
class WidgetTestHelper {
  WidgetTestHelper._();
  
  /// 기본 MaterialApp으로 위젯 래핑
  static Widget wrapWithMaterialApp(
    Widget child, {
    ThemeData? theme,
    Locale? locale,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      theme: theme,
      locale: locale,
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      home: Scaffold(body: child),
    );
  }
  
  /// MediaQuery로 래핑 (반응형 테스트용)
  static Widget wrapWithMediaQuery(
    Widget child, {
    Size size = const Size(375, 812), // iPhone 12 크기
    double devicePixelRatio = 2.0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        devicePixelRatio: devicePixelRatio,
        padding: padding,
      ),
      child: child,
    );
  }
  
  /// 전체 앱 컨텍스트로 래핑
  static Widget wrapWithFullContext(
    Widget child, {
    Size screenSize = const Size(375, 812),
    ThemeData? theme,
  }) {
    return wrapWithMediaQuery(
      wrapWithMaterialApp(child, theme: theme),
      size: screenSize,
    );
  }
  
  /// 특정 텍스트를 찾는 헬퍼
  static Finder findTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) => widget is Text && widget.data?.contains(text) == true,
    );
  }
  
  /// 특정 키를 가진 위젯 찾기
  static Finder findByTestKey(String key) {
    return find.byKey(Key(key));
  }
  
  /// 특정 타입의 위젯이 몇 개 있는지 확인
  static void expectWidgetCount<T>(int expectedCount) {
    expect(find.byType(T), findsNWidgets(expectedCount));
  }
  
  /// 텍스트가 화면에 표시되는지 확인
  static void expectTextVisible(String text) {
    expect(find.text(text), findsOneWidget);
  }
  
  /// 위젯이 화면에 표시되는지 확인
  static void expectWidgetVisible<T>() {
    expect(find.byType(T), findsOneWidget);
  }
}

/// **비동기 테스트 헬퍼**
class AsyncTestHelper {
  AsyncTestHelper._();
  
  /// Future가 완료될 때까지 대기
  static Future<void> waitForFuture(WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
  }
  
  /// 특정 조건이 만족될 때까지 대기
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await tester.pump(pollInterval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within timeout', timeout);
    }
  }
  
  /// 애니메이션이 완료될 때까지 대기
  static Future<void> waitForAnimation(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.pump();
    await tester.pump(duration);
  }
}

/// **Mock 생성 헬퍼**
class MockHelper {
  MockHelper._();
  
  /// Mock 객체의 메서드 호출 설정
  static void setupMockCall<T>(
    Mock mock,
    Symbol method,
    T returnValue, {
    List<dynamic>? positionalArguments,
    Map<Symbol, dynamic>? namedArguments,
  }) {
    when(mock.noSuchMethod(Invocation.method(
      method,
      positionalArguments ?? [],
      namedArguments ?? {},
    ))).thenReturn(returnValue);
  }
  
  /// Future를 반환하는 Mock 메서드 설정
  static void setupMockAsyncCall<T>(
    Mock mock,
    Symbol method,
    T returnValue, {
    List<dynamic>? positionalArguments,
    Map<Symbol, dynamic>? namedArguments,
    Duration delay = Duration.zero,
  }) {
    when(mock.noSuchMethod(Invocation.method(
      method,
      positionalArguments ?? [],
      namedArguments ?? {},
    ))).thenAnswer((_) async {
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
      return returnValue;
    });
  }
  
  /// 에러를 던지는 Mock 메서드 설정
  static void setupMockError(
    Mock mock,
    Symbol method,
    Object error, {
    List<dynamic>? positionalArguments,
    Map<Symbol, dynamic>? namedArguments,
  }) {
    when(mock.noSuchMethod(Invocation.method(
      method,
      positionalArguments ?? [],
      namedArguments ?? {},
    ))).thenThrow(error);
  }
}

/// **테스트 상수**
class TestConstants {
  TestConstants._();
  
  // 테스트용 시간
  static final DateTime testDate = DateTime(2024, 1, 1, 12, 0, 0);
  static final DateTime testDueDate = DateTime(2024, 1, 2, 18, 0, 0);
  
  // 테스트용 문자열
  static const String testTodoTitle = 'Test Todo Item';
  static const String testCategory = 'Test Category';
  static const String testPriority = 'High';
  
  // 테스트용 에러 메시지
  static const String testErrorMessage = 'Test error occurred';
  static const String testNetworkError = 'Network connection failed';
  
  // 테스트용 화면 크기
  static const Size mobileSize = Size(375, 812);
  static const Size tabletSize = Size(768, 1024);
  static const Size desktopSize = Size(1200, 800);
  
  // 테스트용 지연 시간
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);
}

/// **커스텀 매처**
class CustomMatchers {
  CustomMatchers._();
  
  /// 할 일 제목 매처
  static Matcher hasTodoTitle(String expectedTitle) {
    return predicate<TodoItem>(
      (todo) => todo.title == expectedTitle,
      'has title "$expectedTitle"',
    );
  }
  
  /// 할 일 카테고리 매처
  static Matcher hasTodoCategory(String expectedCategory) {
    return predicate<TodoItem>(
      (todo) => todo.category == expectedCategory,
      'has category "$expectedCategory"',
    );
  }
  
  /// 할 일 우선순위 매처
  static Matcher hasTodoPriority(String expectedPriority) {
    return predicate<TodoItem>(
      (todo) => todo.priority == expectedPriority,
      'has priority "$expectedPriority"',
    );
  }
  
  /// 완료된 할 일 매처
  static Matcher isCompletedTodo() {
    return predicate<TodoItem>(
      (todo) => todo.isCompleted,
      'is completed',
    );
  }
  
  /// 기한이 지난 할 일 매처
  static Matcher isOverdueTodo() {
    return predicate<TodoItem>(
      (todo) => todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()),
      'is overdue',
    );
  }
}

/// **타임아웃 예외**
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}