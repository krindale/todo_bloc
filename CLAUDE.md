# CLAUDE.md

## 프로젝트 정보
- **Flutter Todo App** - 크로스 플랫폼 할 일 관리 앱
- **주요 기능**: Todo 관리, Firebase 동기화, 시스템 트레이, 카테고리별 분류

## 자주 사용하는 명령어

### 개발
```bash
flutter run                              # 앱 실행
flutter run -d windows                   # Windows에서 실행  
flutter run -d chrome                    # 웹 브라우저에서 실행
flutter hot-reload                       # 핫 리로드 (r 키)
flutter hot-restart                      # 핫 리스타트 (R 키)
```

### 빌드
```bash
flutter build apk                        # Android APK 빌드
flutter build windows                    # Windows 앱 빌드
flutter build web                        # 웹 앱 빌드
flutter clean                            # 빌드 캐시 정리
flutter pub get                          # 패키지 설치
```

### 테스트 & 분석
```bash
flutter test                             # 모든 테스트 실행
flutter test --coverage                  # 커버리지 포함 테스트
flutter analyze                          # 코드 분석
dart format .                            # 코드 포맷팅
```

### 패키지 관리
```bash
flutter pub upgrade                      # 패키지 업그레이드
flutter pub deps                         # 의존성 트리 확인
flutter pub outdated                     # 구버전 패키지 확인
```

## 주요 파일 구조
```
lib/
├── main.dart                    # 앱 진입점
├── model/                       # 데이터 모델
│   ├── todo_item.dart
│   └── saved_link.dart
├── services/                    # 비즈니스 로직
│   ├── todo_repository.dart     # Repository 인터페이스
│   ├── hive_todo_repository.dart # Hive 구현체
│   └── firebase_sync_service.dart
├── screen/                      # 화면
│   ├── todo_screen.dart         # 메인 할 일 화면
│   └── task_summary_screen.dart
└── widgets/                     # 재사용 위젯
    ├── todo_screen/
    └── task_summary/
```

## 환경 설정

### 필수 도구
- Flutter SDK 3.6.1+
- Dart SDK
- Android Studio / VS Code
- Git

### 주요 패키지
```yaml
dependencies:
  hive: ^2.2.3                   # 로컬 데이터베이스
  firebase_core: ^3.6.0         # Firebase
  window_manager: ^0.3.9        # 데스크톱 창 관리
  system_tray: ^2.0.3           # 시스템 트레이

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4               # 테스팅
  build_runner: ^2.4.4          # 코드 생성
```

## 빌드 & 실행 문제 해결

### 일반적인 에러 해결
```bash
# 캐시 정리
flutter clean && flutter pub get

# 생성된 파일 재빌드
flutter packages pub run build_runner clean
flutter packages pub run build_runner build

# 플랫폼별 정리 (필요시)
cd ios && rm -rf Pods/ && pod install    # iOS
```

### Windows 빌드 에러
```bash
flutter config --enable-windows-desktop
flutter build windows --release
```

### 웹 빌드 에러  
```bash
flutter config --enable-web
flutter build web --release
```

## 테스트

### 주요 테스트 파일
- `test/services/task_statistics_service_test.dart`
- `test/services/task_categorization_service_test.dart` 
- `test/model/todo_item_test.dart`

### 테스트 실행
```bash
flutter test test/services/                    # 서비스 테스트만
flutter test test/model/                       # 모델 테스트만
flutter test --coverage                        # 전체 + 커버리지
```

## 배포

### Android
```bash
flutter build apk --release                   # APK 파일
flutter build appbundle --release             # Play Store용 AAB
```

### Windows
```bash
flutter build windows --release
# 결과물: build/windows/x64/runner/Release/
```

### Web
```bash
flutter build web --release
# 결과물: build/web/
```

## 개발 팁

1. **Hot Reload**: `r` 키로 빠른 UI 업데이트
2. **Debug Console**: `flutter logs`로 실시간 로그 확인
3. **Widget Inspector**: Flutter DevTools에서 UI 구조 분석
4. **Performance**: `flutter run --profile`로 성능 측정
5. **Dependency Graph**: `flutter pub deps`로 패키지 관계 확인

## 이 프로젝트 특징

- **SOLID 원칙** 적용된 클린 아키텍처
- **플랫폼별 최적화**: 모바일(Hive+Firebase), 데스크톱(Firebase+SystemTray)
- **의존성 주입** 패턴으로 테스트 용이성 확보
- **Repository 패턴**으로 데이터 계층 추상화

## PR 전 테스트 코드 작성 가이드

### 테스트 작성 원칙
1. **AAA 패턴**: Arrange, Act, Assert
2. **단위 테스트 우선**: 각 메서드/클래스별 독립적 테스트
3. **의존성 Mock**: 외부 의존성은 Mock 객체로 대체
4. **경계값 테스트**: null, 빈 값, 극값 등 테스트

### 새로운 서비스 테스트 작성

#### 1. Repository 테스트 템플릿
```dart
// test/services/my_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([PlatformStrategy])
import 'my_repository_test.mocks.dart';

void main() {
  group('MyRepository', () {
    late MyRepository repository;
    late MockPlatformStrategy mockStrategy;

    setUp(() {
      mockStrategy = MockPlatformStrategy();
      repository = MyRepository(mockStrategy);
    });

    test('should return items when getTodos called', () async {
      // Arrange
      final expectedItems = [TodoItem(title: 'Test')];
      when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result, isA<List<TodoItem>>());
      verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
    });

    test('should handle empty list', () async {
      // Arrange
      when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result, isEmpty);
    });

    test('should throw exception on invalid input', () {
      // Arrange & Act & Assert
      expect(
        () => repository.addTodo(null),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

#### 2. Service 클래스 테스트 템플릿
```dart
// test/services/my_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('MyService', () {
    late MyService service;
    
    setUp(() {
      service = MyService();
    });

    tearDown(() {
      // 리소스 정리
    });

    test('should process data correctly', () {
      // Arrange
      final inputData = ['item1', 'item2'];
      
      // Act
      final result = service.processData(inputData);
      
      // Assert
      expect(result, isNotNull);
      expect(result.length, equals(2));
    });

    test('should handle null input gracefully', () {
      // Act & Assert
      expect(() => service.processData(null), returnsNormally);
    });
  });
}
```

#### 3. Widget 테스트 템플릿
```dart
// test/widgets/my_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('MyWidget', () {
    testWidgets('should display title correctly', (tester) async {
      // Arrange
      const testTitle = 'Test Title';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MyWidget(title: testTitle),
        ),
      );
      
      // Assert
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      // Arrange
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MyWidget(
            onTap: () => tapped = true,
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(MyWidget));
      await tester.pump();
      
      // Assert
      expect(tapped, isTrue);
    });
  });
}
```

### Mock 생성 및 관리

#### Mockito 설정
```bash
# pubspec.yaml의 dev_dependencies에 추가
mockito: ^5.4.4
build_runner: ^2.4.4

# Mock 생성 명령어
flutter packages pub run build_runner build
```

#### Mock 클래스 생성 예시
```dart
// test/mocks/mock_services.dart
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/services/todo_repository.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';

@GenerateMocks([
  TodoRepository,
  FirebaseSyncService,
  TaskCategorizationService,
])
void main() {}
```

### 테스트 커버리지 목표

#### 필수 테스트 대상
- [ ] **새로운 Service 클래스**: 모든 public 메서드
- [ ] **Repository 구현체**: CRUD 작업 및 에러 처리
- [ ] **Model 클래스**: 생성자, getter/setter, 유효성 검증
- [ ] **Utility 함수**: 모든 분기 조건
- [ ] **Widget**: 핵심 UI 동작 및 상호작용

#### 커버리지 측정
```bash
# 커버리지 생성
flutter test --coverage

# HTML 리포트 생성 (선택사항)
genhtml coverage/lcov.info -o coverage/html
```

### PR 전 테스트 체크리스트

#### 1. 테스트 작성 완료 확인
```bash
# 새로 추가한 파일에 대한 테스트 존재 여부 확인
find lib/ -name "*.dart" -not -path "*/widgets/*" | while read file; do
  test_file="test/${file#lib/}"
  test_file="${test_file%.dart}_test.dart"
  if [ ! -f "$test_file" ]; then
    echo "Missing test: $test_file"
  fi
done
```

#### 2. 테스트 실행 및 통과 확인
```bash
# 모든 테스트 실행
flutter test

# 특정 테스트만 실행 (새로 작성한 것)
flutter test test/services/new_service_test.dart

# 커버리지 포함 실행
flutter test --coverage
```

#### 3. 코드 품질 확인
```bash
# 정적 분석
flutter analyze

# 포맷팅 확인
dart format --set-exit-if-changed .

# 의존성 검증
flutter pub deps
```

#### 4. 통합 테스트 (필요시)
```bash
# 통합 테스트 실행
flutter test integration_test/
```

### 일반적인 테스트 시나리오

#### Repository 테스트 시나리오
- ✅ **정상 동작**: 데이터 저장/조회/수정/삭제
- ✅ **빈 데이터**: 빈 리스트 처리
- ✅ **null 처리**: null 입력값 처리
- ✅ **플랫폼별 동작**: Firebase vs 로컬 DB
- ✅ **에러 처리**: 네트워크 오류, DB 오류 등

#### Service 테스트 시나리오  
- ✅ **비즈니스 로직**: 핵심 기능 동작
- ✅ **의존성 호출**: 다른 서비스 올바른 호출
- ✅ **상태 관리**: 내부 상태 변경 확인
- ✅ **예외 상황**: 잘못된 입력, 시스템 오류

#### Widget 테스트 시나리오
- ✅ **UI 렌더링**: 올바른 위젯 표시
- ✅ **사용자 상호작용**: 탭, 스와이프 등
- ✅ **상태 변경**: 상태에 따른 UI 업데이트
- ✅ **콜백 호출**: 이벤트 핸들러 실행

### 테스트 실행 자동화

#### pre-commit hook 설정
```bash
# .git/hooks/pre-commit 파일 생성
#!/bin/sh
echo "Running tests before commit..."
flutter test
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi

flutter analyze
if [ $? -ne 0 ]; then
  echo "Analysis failed. Commit aborted."  
  exit 1
fi
```

#### GitHub Actions 워크플로우
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug
```

## 문제 발생 시 체크리스트

1. `flutter doctor` - 환경 설정 확인
2. `flutter clean && flutter pub get` - 캐시 정리
3. `flutter analyze` - 코드 문제 확인  
4. `flutter test` - 테스트 통과 여부 확인
5. 특정 플랫폼 문제 시 해당 플랫폼 설정 재확인