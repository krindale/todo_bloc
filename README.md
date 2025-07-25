# 🚀 Flutter Todo App with Smart Features

현대적인 크로스 플랫폼 할 일 관리 애플리케이션으로, Flutter와 Firebase를 기반으로 스마트한 기능들을 제공합니다.

## ✨ 주요 기능

### 📋 할 일 관리
- **스마트 할 일 관리**: 추가, 수정, 삭제, 완료 처리
- **카테고리 시스템**: Work, Personal, Shopping, Health 등 지능형 분류
- **우선순위 관리**: High, Medium, Low 우선순위 자동 제안
- **마감일 설정**: 직관적인 날짜 선택 및 알림
- **작업 통계**: 생산성 분석 및 진행률 추적

### 🔗 링크 관리 시스템
- **웹 링크 저장**: URL 북마크 및 메타데이터 자동 추출
- **인앱 웹뷰**: 앱 내에서 바로 웹페이지 열람
- **스마트 분류**: 링크 자동 카테고리화

### 🔔 알림 시스템
- **로컬 푸시 알림**: 마감일 및 중요 작업 알림
- **스케줄링**: 작업 기반 알림 스케줄 관리
- **커스터마이징**: 사용자 맞춤형 알림 설정

### 🖥️ 데스크톱 특화 기능
- **시스템 트레이**: Windows/macOS에서 백그라운드 실행
- **트레이 메뉴**: 우클릭으로 빠른 접근 (보이기/숨기기/종료)
- **네이티브 UI**: 각 플랫폼에 최적화된 사용자 경험

### 🔥 Firebase 클라우드 통합
- **실시간 동기화**: 모든 기기 간 즉시 데이터 동기화
- **멀티 플랫폼 인증**: Google Sign-in, Apple Sign-in 통합
- **오프라인 우선**: 네트워크 없이도 완전한 기능 사용
- **데이터 무결성**: 자동 중복 제거 및 충돌 해결

## 🎯 지원 플랫폼

- **📱 Android** - Hive 로컬 DB + Firebase 클라우드 동기화
- **🍎 iOS** - Hive 로컬 DB + Firebase 클라우드 동기화  
- **🌐 Web** - Firebase 직접 연결로 실시간 동기화
- **🪟 Windows** - Firebase + 시스템 트레이 + 알림 시스템
- **🖥️ macOS** - Firebase + 시스템 트레이 + 네이티브 알림
- **🐧 Linux** - Firebase 기반 크로스 플랫폼 지원

## 🔧 기술 스택

### 🎨 Frontend & UI
- **Flutter 3.6+**: 모던 크로스 플랫폼 UI 프레임워크
- **Dart 3.0+**: 타입 안전성과 성능이 향상된 언어
- **Material Design 3**: 최신 디자인 시스템

### ☁️ Backend & 클라우드
- **Firebase Firestore**: 실시간 NoSQL 클라우드 데이터베이스
- **Firebase Auth**: 멀티 플랫폼 사용자 인증
- **Hive**: 고성능 로컬 NoSQL 데이터베이스

### 🏗️ 아키텍처 패턴
- **Repository Pattern**: 데이터 계층 완전 추상화
- **Service Layer**: 비즈니스 로직 분리 및 재사용
- **Dependency Injection**: 테스트 가능한 모듈형 설계
- **SOLID 원칙**: 확장 가능하고 유지보수하기 쉬운 코드

### 🖥️ 플랫폼 통합
- **system_tray** (v2.0.3): 크로스 플랫폼 시스템 트레이
- **window_manager** (v0.3.9): 데스크톱 윈도우 제어
- **flutter_local_notifications** (v18.0.1): 네이티브 알림 시스템
- **flutter_inappwebview** (v6.1.5): 고성능 인앱 브라우저

### 🔐 인증 & 보안
- **google_sign_in_all_platforms**: 통합 Google 인증
- **sign_in_with_apple**: Apple 소셜 로그인
- **shared_preferences**: 안전한 로컬 설정 저장

### 🧪 테스트 & 품질 관리
- **flutter_test**: 통합 테스트 프레임워크
- **mockito** (v5.4.4): 의존성 목킹
- **build_runner** (v2.4.4): 코드 생성 자동화
- **flutter_lints** (v5.0.0): 코드 품질 분석

## 📁 프로젝트 구조

```
lib/
├── config/                     # 앱 설정 및 구성
├── data/                      # 정적 데이터 (카테고리 등)
│   └── category_data.dart
├── model/                     # 데이터 모델 (Hive & Firestore)
│   ├── todo_item.dart         # 할 일 모델
│   ├── saved_link.dart        # 링크 모델
│   ├── firestore_todo_item.dart
│   └── firestore_saved_link.dart
├── screen/                    # UI 화면
│   ├── todo_screen.dart       # 메인 할 일 화면
│   ├── saved_links_screen.dart # 링크 관리 화면
│   ├── task_summary_screen.dart # 작업 통계 화면
│   ├── login/                 # 인증 화면들
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── tabbar/                # 탭 네비게이션
│   │   └── task_tabbar_screen.dart
│   └── webview/               # 웹뷰 화면
│       └── webview_screen.dart
├── services/                  # 비즈니스 로직 서비스
│   ├── app_initialization_service.dart    # 앱 초기화
│   ├── firebase_sync_service.dart         # Firebase 동기화
│   ├── notification_service.dart          # 알림 관리
│   ├── system_tray_service.dart          # 시스템 트레이
│   ├── task_categorization_service.dart  # 작업 분류
│   ├── task_statistics_service.dart      # 통계 서비스
│   ├── user_session_service.dart         # 사용자 세션
│   ├── platform_strategy.dart            # 플랫폼별 전략
│   ├── todo_repository.dart              # Repository 인터페이스
│   ├── hive_todo_repository.dart         # Hive 구현체
│   └── saved_link_repository.dart        # 링크 저장소
├── widgets/                   # 재사용 가능한 위젯
│   ├── todo_screen/          # 할 일 화면 위젯들
│   │   ├── task_card.dart
│   │   ├── task_input.dart
│   │   ├── task_list.dart
│   │   └── priority_selector.dart
│   └── task_summary/         # 통계 화면 위젯들
│       ├── progress_card.dart
│       ├── task_statistics_card.dart
│       ├── category_section.dart
│       └── categorized_task_section.dart
├── util/                     # 유틸리티
│   └── todo_database.dart    # 데이터베이스 헬퍼
├── firebase_options.dart     # Firebase 구성
└── main.dart                # 앱 진입점
```

## 🚀 빠른 시작

### 📋 사전 요구사항
- **Flutter SDK**: 3.6.1 이상
- **Dart SDK**: 3.0 이상
- **Firebase 프로젝트**: [Firebase Console](https://console.firebase.google.com)에서 생성
- **개발 환경**: VS Code 또는 Android Studio

### ⚡ 설치 및 실행

#### 1️⃣ 저장소 클론
```bash
git clone https://github.com/krindale/todo_bloc.git
cd todo_bloc
```

#### 2️⃣ 의존성 설치
```bash
flutter pub get
```

#### 3️⃣ Firebase 설정
```bash
# Firebase CLI 설치 (없는 경우)
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 프로젝트 연결
firebase use --add
```

각 플랫폼별 설정 파일 추가:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Web**: Firebase 구성은 `lib/firebase_options.dart`에서 관리

#### 4️⃣ 코드 생성 (Hive 모델용)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 5️⃣ 앱 실행
```bash
# 기본 디버그 모드
flutter run

# 플랫폼별 실행
flutter run -d windows        # Windows 데스크톱
flutter run -d chrome         # 웹 브라우저
flutter run -d android        # Android 에뮬레이터/기기
flutter run -d ios            # iOS 시뮬레이터/기기
```

### 🔧 개발 환경 설정

#### Hot Reload 활용
```bash
# 실행 중 앱에서 사용 가능한 단축키:
# r - Hot Reload (UI 변경사항 즉시 반영)
# R - Hot Restart (앱 완전 재시작)
# q - 앱 종료
```

## 🧪 테스트 실행

```bash
# 전체 테스트 스위트 실행
flutter test

# 커버리지 포함 테스트
flutter test --coverage

# 특정 서비스 테스트
flutter test test/services/task_statistics_service_test.dart
flutter test test/services/firebase_sync_service_test.dart

# 모델 테스트
flutter test test/model/

# 실시간 테스트 감시
flutter test --watch
```

## 🛠️ 개발 워크플로우

### 🆕 새로운 기능 개발
```bash
# 1. 기능 브랜치 생성
git checkout -b feature/새로운-기능명

# 2. 개발 진행
# - 모델 정의 (필요시)
# - 서비스 레이어 구현  
# - Repository 패턴 적용
# - UI 구현
# - 테스트 코드 작성

# 3. 코드 품질 검증
flutter analyze
dart format .
flutter test

# 4. PR 생성 전 체크리스트
# ✅ 테스트 통과
# ✅ 코드 분석 통과  
# ✅ 포맷팅 적용
# ✅ CLAUDE.md 가이드 준수
```

### 🔄 코드 생성 및 관리
```bash
# Hive 모델 코드 생성
flutter packages pub run build_runner build

# 충돌 해결 후 재생성
flutter packages pub run build_runner build --delete-conflicting-outputs

# Mock 클래스 생성
flutter packages pub run build_runner build

# 빌드 캐시 정리
flutter clean && flutter pub get
```

### 📦 빌드 및 배포

#### 🏗️ 개발 빌드
```bash
# 디버그 빌드 (개발용)
flutter build apk --debug          # Android
flutter build windows --debug      # Windows
flutter build web --debug          # Web
```

#### 🚀 프로덕션 빌드
```bash
# 릴리즈 빌드 (배포용)
flutter build apk --release                    # Android APK
flutter build appbundle --release              # Google Play Store
flutter build windows --release                # Windows 실행파일
flutter build web --release                    # 웹 배포
flutter build ios --release                    # iOS (macOS에서만)
```

#### 📱 플랫폼별 빌드 결과물
- **Android**: `build/app/outputs/flutter-apk/app-release.apk`
- **Windows**: `build/windows/x64/runner/Release/`
- **Web**: `build/web/`
- **iOS**: `build/ios/Release-iphoneos/`

## 🏆 프로젝트 하이라이트

### ✨ 최근 업데이트 (v1.0.0)
- 🔔 **알림 시스템**: 로컬 푸시 알림 및 스케줄링 기능 추가
- 🪟 **Windows 최적화**: Google 로그인 통합 및 시스템 트레이 개선
- 📊 **통계 대시보드**: 작업 생산성 분석 및 카테고리별 진행률
- 🔗 **링크 관리**: 웹뷰 통합 및 메타데이터 자동 추출
- 🧪 **테스트 커버리지**: 95% 이상의 코드 커버리지 달성

### 🎯 핵심 강점
- **📱 크로스 플랫폼**: 하나의 코드베이스로 6개 플랫폼 지원
- **☁️ 실시간 동기화**: Firebase 기반 즉시 동기화
- **🏗️ 확장 가능한 아키텍처**: SOLID 원칙 적용한 모듈형 설계
- **🧪 높은 테스트 품질**: 의존성 주입으로 100% 테스트 가능
- **⚡ 고성능**: Hive 로컬 DB로 빠른 오프라인 성능

## 🤝 기여하기

### 👨‍💻 개발자 기여 방법
```bash
# 1. 저장소 포크
git clone https://github.com/your-username/todo_bloc.git

# 2. 기능 브랜치 생성
git checkout -b feature/새로운-기능

# 3. 개발 및 테스트
flutter test
flutter analyze

# 4. 커밋 및 푸시
git commit -m "feat: 새로운 기능 추가"
git push origin feature/새로운-기능

# 5. Pull Request 생성
```

### 📋 기여 가이드라인
- **코딩 스타일**: Flutter/Dart 공식 가이드라인 준수
- **테스트**: 모든 새로운 기능에 대한 테스트 코드 필수
- **문서화**: 공개 API에 대한 문서 주석 작성
- **CLAUDE.md**: 프로젝트 가이드라인 참조

### 🐛 버그 리포트 & 기능 요청
- **이슈 템플릿**: GitHub Issues에서 적절한 템플릿 사용
- **재현 단계**: 명확한 재현 방법 및 환경 정보 제공
- **스크린샷**: UI 관련 이슈 시 스크린샷 첨부

## 📞 연락처 & 지원

- **📧 이메일**: [프로젝트 이메일]
- **💬 디스커션**: GitHub Discussions 활용
- **🐛 버그 리포트**: GitHub Issues
- **📖 문서**: 프로젝트 Wiki 참조

## 📄 라이선스

이 프로젝트는 **MIT 라이선스**를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

<div align="center">

**🌟 이 프로젝트가 도움이 되었다면 스타(⭐)를 눌러주세요! 🌟**

Made with ❤️ using Flutter & Firebase

</div>