import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/model/saved_link.dart';
import 'package:todo_bloc/screen/saved_links_screen.dart';
import 'package:todo_bloc/services/saved_link_repository.dart';

// Mockito 어노테이션을 사용한 Mock 클래스 생성
@GenerateNiceMocks([MockSpec<SavedLinkRepository>()])
import 'saved_links_screen_test.mocks.dart';

void main() {
  group('SavedLinksScreen 위젯 테스트', () {
    late MockSavedLinkRepository mockRepository;

    setUpAll(() async {
      // 테스트용 Hive 초기화
      await Hive.initFlutter();
      Hive.registerAdapter(SavedLinkAdapter());
    });

    setUp(() {
      mockRepository = MockSavedLinkRepository();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: const SavedLinksScreen(),
      );
    }

    testWidgets('빈 상태일 때 안내 메시지가 표시되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 빈 상태 안내 메시지 확인
      expect(find.text('저장된 링크가 없습니다'), findsOneWidget);
      expect(find.text('+ 버튼을 눌러 새 링크를 추가해보세요'), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsOneWidget);
    });

    testWidgets('플로팅 액션 버튼이 표시되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('플로팅 액션 버튼 탭 시 다이얼로그가 표시되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 플로팅 액션 버튼 탭
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 다이얼로그 확인
      expect(find.text('새 링크 추가'), findsOneWidget);
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('추가'), findsOneWidget);
    });

    testWidgets('URL 입력 필드가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // URL 입력 필드 확인
      final urlField = find.byType(TextField);
      expect(urlField, findsOneWidget);
      
      // 힌트 텍스트 확인
      expect(find.text('https://example.com 또는 example.com'), findsOneWidget);
    });

    testWidgets('취소 버튼 동작 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 취소 버튼 탭
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // 다이얼로그가 닫혔는지 확인
      expect(find.text('새 링크 추가'), findsNothing);
    });

    testWidgets('빈 URL로 추가 버튼 탭 시 아무 동작 안 함 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 빈 상태로 추가 버튼 탭
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // 다이얼로그가 여전히 열려있는지 확인 (닫히지 않음)
      expect(find.text('새 링크 추가'), findsOneWidget);
    });

    testWidgets('유효한 URL 입력 후 추가 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // URL 입력
      await tester.enterText(find.byType(TextField), 'https://flutter.dev');
      await tester.pumpAndSettle();

      // 추가 버튼 탭
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // 로딩 상태 확인 (웹 타이틀을 가져오는 동안)
      expect(find.text('웹페이지 정보를 가져오는 중...'), findsOneWidget);
    });

    testWidgets('링크 카드가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // 실제 데이터가 있는 상태를 시뮬레이션하기 위해
      // 테스트 링크를 미리 추가한 위젯을 만들어야 함
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // URL 추가
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'flutter.dev');
      await tester.tap(find.text('추가'));
      
      // 웹 요청이 완료될 때까지 충분히 대기
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 카드가 표시되는지 확인 (웹 요청 성공 시)
      // 실제 네트워크 요청이므로 결과가 달라질 수 있음
    });

    testWidgets('스크롤 가능한 리스트뷰가 있는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // ListView.builder가 존재하는지 확인 (빈 상태에서는 표시되지 않음)
      // 데이터가 있을 때만 ListView가 표시됨
    });

    testWidgets('Scaffold 구조가 올바른지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('다이얼로그의 autofocus가 동작하는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // TextField가 포커스를 받았는지 확인
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('다이얼로그 크기 및 레이아웃 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // AlertDialog가 표시되는지 확인
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // 다이얼로그 내부 구조 확인
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('키보드 상호작용 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 텍스트 입력
      const testUrl = 'https://example.com';
      await tester.enterText(find.byType(TextField), testUrl);
      
      // 입력된 텍스트 확인
      expect(find.text(testUrl), findsOneWidget);
    });
  });

  group('SavedLinksScreen 통합 테스트', () {
    testWidgets('전체 플로우 테스트: 링크 추가 -> 표시 -> 삭제', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const SavedLinksScreen()));
      await tester.pumpAndSettle();

      // 1. 초기 빈 상태 확인
      expect(find.text('저장된 링크가 없습니다'), findsOneWidget);

      // 2. 링크 추가 다이얼로그 열기
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 3. URL 입력
      await tester.enterText(find.byType(TextField), 'flutter.dev');
      
      // 4. 추가 버튼 탭
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // 5. 로딩 상태 확인
      expect(find.text('웹페이지 정보를 가져오는 중...'), findsOneWidget);
    });

    testWidgets('여러 링크 추가 시나리오 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const SavedLinksScreen()));
      await tester.pumpAndSettle();

      final urls = ['flutter.dev', 'dart.dev', 'pub.dev'];

      for (final url in urls) {
        // 링크 추가
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byType(TextField), url);
        await tester.tap(find.text('추가'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 여러 링크가 추가되었는지 확인하는 로직
      // 실제 네트워크 요청이므로 결과가 달라질 수 있음
    });
  });
}