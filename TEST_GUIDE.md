# 🧪 다크모드 테스트 가이드

다크모드 구현에 대한 포괄적인 테스트 가이드입니다.

## 📋 테스트 개요

### 구현된 테스트 종류

1. **단위 테스트 (Unit Tests)**
   - `ThemeService` 로직 테스트
   - `AppTheme` 색상 팔레트 및 테마 데이터 테스트

2. **위젯 테스트 (Widget Tests)**
   - `ThemeToggleSwitch` UI 동작 테스트
   - 테마 변경 시 위젯 상태 업데이트 테스트

3. **통합 테스트 (Integration Tests)**
   - 전체 앱 테마 통합 테스트
   - 메인 앱에서의 테마 전환 테스트

4. **시나리오 테스트 (Scenario Tests)**
   - 실제 사용자 시나리오 기반 E2E 테스트
   - 에러 복구 및 성능 테스트

## 🚀 테스트 실행 방법

### 전체 테스트 스위트 실행
```bash
# 다크모드 관련 모든 테스트 실행
flutter test test/theme_test_suite.dart

# 전체 프로젝트 테스트 실행
flutter test

# 커버리지 포함 실행
flutter test --coverage
```

### 개별 테스트 파일 실행
```bash
# ThemeService 단위 테스트
flutter test test/services/theme_service_test.dart

# ThemeToggleSwitch 위젯 테스트
flutter test test/widgets/theme/theme_toggle_switch_test.dart

# AppTheme 테마 데이터 테스트
flutter test test/theme/app_theme_test.dart

# 통합 테스트
flutter test test/integration/theme_integration_test.dart

# 시나리오 테스트
flutter test test/integration/theme_scenario_test.dart
```

### 특정 테스트 그룹 실행
```bash
# 단위 테스트만 실행
flutter test test/services/ test/theme/

# 위젯 테스트만 실행
flutter test test/widgets/theme/

# 통합 테스트만 실행
flutter test test/integration/
```

## 📊 테스트 범위

### ThemeService 테스트 (`test/services/theme_service_test.dart`)
- ✅ 초기화 및 기본 상태
- ✅ 테마 설정 변경 (light/dark/system)
- ✅ 토글 기능
- ✅ 상태 변경 알림 (ChangeNotifier)
- ✅ 설정 저장 및 로드 (SharedPreferences)
- ✅ 에러 처리 및 복구
- ✅ 시스템 테마 변경 감지

### ThemeToggleSwitch 테스트 (`test/widgets/theme/theme_toggle_switch_test.dart`)
- ✅ 컴팩트 모드 렌더링
- ✅ 전체 모드 렌더링
- ✅ 아이콘 변경 애니메이션
- ✅ 터치 상호작용
- ✅ 테마 설정 메뉴
- ✅ 접근성 요소
- ✅ 에러 처리

### AppTheme 테스트 (`test/theme/app_theme_test.dart`)
- ✅ 라이트/다크 테마 데이터 구조
- ✅ 색상 팔레트 일관성
- ✅ 컴포넌트별 테마 설정
- ✅ 유틸리티 메서드 동작
- ✅ 접근성 대비율 검증
- ✅ 테마 일관성 검증

### 통합 테스트 (`test/integration/theme_integration_test.dart`)
- ✅ 앱 초기화 시 테마 적용
- ✅ 전체 앱 테마 전환
- ✅ UI 컴포넌트 테마 적용
- ✅ 시스템 테마 감지
- ✅ 성능 및 안정성
- ✅ 메모리 관리

### 시나리오 테스트 (`test/integration/theme_scenario_test.dart`)
- ✅ 신규 사용자 첫 실행
- ✅ 기존 사용자 재방문
- ✅ 연속적인 테마 전환
- ✅ 시스템 테마 상호작용
- ✅ 사용자 경험 시나리오
- ✅ 에러 복구 시나리오
- ✅ 성능 및 메모리 시나리오

## 🎯 테스트 품질 지표

### 커버리지 목표
- **단위 테스트**: 95% 이상
- **위젯 테스트**: 90% 이상
- **통합 테스트**: 85% 이상

### 성능 지표
- **테마 전환 시간**: < 300ms
- **100회 연속 전환**: < 10초
- **메모리 누수**: 0건
- **에러 발생**: 0건

## 🔧 테스트 개발 가이드

### 새로운 테스트 추가 시
1. 적절한 디렉토리에 테스트 파일 생성
2. 기존 테스트 구조와 일관성 유지
3. AAA 패턴 (Arrange, Act, Assert) 적용
4. 의미있는 테스트 이름 사용
5. `theme_test_suite.dart`에 추가

### 테스트 작성 규칙
```dart
// ✅ 좋은 테스트 이름
test('should change to dark theme when user taps toggle switch', () async {
  // ...
});

// ❌ 나쁜 테스트 이름  
test('test theme change', () async {
  // ...
});
```

### Mock 사용
```dart
setUp(() {
  // SharedPreferences 모킹
  SharedPreferences.setMockInitialValues({});
  
  // ThemeService 리셋
  ThemeService.resetForTesting();
});
```

## 🐛 테스트 문제 해결

### 자주 발생하는 문제들

1. **SharedPreferences 에러**
   ```dart
   // 해결: setUp에서 모킹 초기화
   SharedPreferences.setMockInitialValues({});
   ```

2. **ThemeService 싱글톤 문제**
   ```dart
   // 해결: 각 테스트마다 리셋
   ThemeService.resetForTesting();
   ```

3. **Widget 애니메이션 대기**
   ```dart
   // 해결: pumpAndSettle 사용
   await tester.pumpAndSettle();
   ```

4. **비동기 상태 변경**
   ```dart
   // 해결: Future 완료 대기
   await service.setThemePreference(ThemePreference.dark);
   await tester.pumpAndSettle();
   ```

## 📈 CI/CD 통합

### GitHub Actions에서 테스트 실행
```yaml
- name: Run Theme Tests
  run: |
    flutter test test/theme_test_suite.dart
    flutter test --coverage
```

### 테스트 실패 시 체크사항
1. 모든 의존성 설치 확인 (`flutter pub get`)
2. Mock 설정 확인
3. 비동기 작업 완료 대기
4. 플랫폼별 동작 차이 확인

## 📚 추가 자료

- [Flutter Testing 가이드](https://docs.flutter.dev/testing)
- [Widget Testing 모범 사례](https://docs.flutter.dev/testing/widget-tests)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [테스트 커버리지 분석](https://docs.flutter.dev/testing/code-coverage)

---

**테스트 실행 확인:**
```bash
flutter test test/theme_test_suite.dart --reporter expanded
```

모든 테스트가 통과하면 다크모드 구현이 올바르게 작동하는 것입니다! 🎉