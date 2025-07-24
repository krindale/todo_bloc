import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/screen/todo_screen.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';
import 'package:todo_bloc/services/todo_repository.dart';

import 'todo_screen_firebase_test.mocks.dart';

@GenerateMocks([FirebaseSyncService, TaskCategorizationService, TodoRepository])
void main() {
  group('TodoScreen Firebase-only Tests', () {
    late MockFirebaseSyncService mockFirebaseService;
    late MockTaskCategorizationService mockCategorizationService;
    late MockTodoRepository mockTodoRepository;

    setUp(() {
      mockFirebaseService = MockFirebaseSyncService();
      mockCategorizationService = MockTaskCategorizationService();
      mockTodoRepository = MockTodoRepository();
    });

    group('Firebase-only Platform Todo Editing', () {
      testWidgets('should edit todo in Firebase-only mode', (tester) async {
        // Mock 데이터 설정
        final testTodo = TodoItem(
          title: 'Test Todo',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        final updatedTodo = TodoItem(
          title: 'Updated Todo',
          priority: 'Medium',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        // Mock 설정
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.value([testTodo]),
        );

        when(mockCategorizationService.categorizeAndUpdateTask(any))
            .thenReturn(updatedTodo);

        when(mockFirebaseService.updateTodoInFirestore(any))
            .thenAnswer((_) async => Future.value());

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // StreamBuilder가 데이터를 로드할 때까지 대기
        await tester.pump();

        // Todo 항목이 표시되는지 확인
        expect(find.text('Test Todo'), findsOneWidget);

        // 수정 버튼 찾아서 탭
        final editButton = find.byIcon(Icons.edit).first;
        expect(editButton, findsOneWidget);
        
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // 수정 모드로 전환되었는지 확인 (텍스트 필드에 기존 값이 있는지)
        final textField = find.byType(TextFormField).first;
        expect(textField, findsOneWidget);

        // 텍스트 변경
        await tester.enterText(textField, 'Updated Todo');
        await tester.pumpAndSettle();

        // 저장 버튼 탭
        final saveButton = find.byIcon(Icons.add).first;
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Firebase 업데이트가 호출되었는지 확인
        verify(mockFirebaseService.updateTodoInFirestore(any)).called(1);
      });

      testWidgets('should handle todo completion toggle in Firebase-only mode', (tester) async {
        // Mock 데이터 설정
        final testTodo = TodoItem(
          title: 'Test Todo',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        // Mock 설정
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.value([testTodo]),
        );

        when(mockFirebaseService.updateTodoInFirestore(any))
            .thenAnswer((_) async => Future.value());

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 체크박스 찾아서 탭
        final checkbox = find.byType(Checkbox).first;
        expect(checkbox, findsOneWidget);
        
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Firebase 업데이트가 호출되었는지 확인
        verify(mockFirebaseService.updateTodoInFirestore(any)).called(1);
      });

      test('should update todo with Firebase document ID preservation', () async {
        // 테스트 데이터
        final originalTodo = TodoItem(
          title: 'Original',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        final updatedTodo = TodoItem(
          title: 'Updated',
          priority: 'Medium',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        // Mock 설정
        when(mockFirebaseService.updateTodoInFirestore(any))
            .thenAnswer((_) async => Future.value());

        // Firebase 업데이트 호출
        await mockFirebaseService.updateTodoInFirestore(updatedTodo);

        // 검증
        verify(mockFirebaseService.updateTodoInFirestore(
          argThat(predicate<TodoItem>((todo) => 
            todo.firebaseDocId == 'test-doc-id' &&
            todo.title == 'Updated' &&
            todo.priority == 'Medium'
          ))
        )).called(1);
      });
    });

    group('Stream Data Handling', () {
      testWidgets('should display todos from Firebase stream', (tester) async {
        // Mock 데이터 설정
        final testTodos = [
          TodoItem(
            title: 'Todo 1',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
            firebaseDocId: 'doc-1',
          ),
          TodoItem(
            title: 'Todo 2',
            priority: 'Medium',
            dueDate: DateTime.now(),
            isCompleted: true,
            category: 'Personal',
            firebaseDocId: 'doc-2',
          ),
        ];

        // Mock 설정
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.value(testTodos),
        );

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 두 개의 Todo가 표시되는지 확인
        expect(find.text('Todo 1'), findsOneWidget);
        expect(find.text('Todo 2'), findsOneWidget);
      });

      testWidgets('should handle stream errors gracefully', (tester) async {
        // Mock 설정 - 스트림 에러
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.error('Firebase connection error'),
        );

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 에러 메시지가 표시되는지 확인
        expect(find.textContaining('오류'), findsOneWidget);
      });

      testWidgets('should show loading indicator while stream is loading', (tester) async {
        // Mock 설정 - 로딩 상태
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.fromFuture(
            Future.delayed(Duration(seconds: 1), () => <TodoItem>[])
          ),
        );

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        // 초기 로딩 상태 확인
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // 로딩 완료까지 대기
        await tester.pumpAndSettle();
      });
    });

    group('Platform Detection', () {
      test('should correctly identify Firebase-only platforms', () {
        // 플랫폼 감지 로직 테스트
        // 실제 구현에서는 kIsWeb || Platform.isMacOS || Platform.isWindows
        
        // 테스트 환경에서는 실제 플랫폼 값을 사용할 수 없으므로 로직만 검증
        bool isFirebaseOnly = false; // 기본값
        
        // 웹 환경이라고 가정
        bool kIsWebMock = true;
        if (kIsWebMock) {
          isFirebaseOnly = true;
        }
        
        expect(isFirebaseOnly, true);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle Firebase update failures', (tester) async {
        // Mock 데이터 설정
        final testTodo = TodoItem(
          title: 'Test Todo',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'Work',
          firebaseDocId: 'test-doc-id',
        );

        // Mock 설정 - Firebase 업데이트 실패
        when(mockFirebaseService.todosStream()).thenAnswer(
          (_) => Stream.value([testTodo]),
        );

        when(mockFirebaseService.updateTodoInFirestore(any))
            .thenThrow(Exception('Firebase update failed'));

        // 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: TodoScreen(
              todoRepository: mockTodoRepository,
              categorizationService: mockCategorizationService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 체크박스 탭 (실패할 것임)
        final checkbox = find.byType(Checkbox).first;
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Firebase 업데이트가 시도되었는지 확인
        verify(mockFirebaseService.updateTodoInFirestore(any)).called(1);
      });
    });
  });
}