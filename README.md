# Todo App with Firebase Integration

크로스 플랫폼 Todo 관리 애플리케이션으로 Flutter와 Firebase를 활용하여 개발되었습니다.

## 주요 기능

### 📱 핵심 기능
- **Todo 관리**: 할일 추가, 수정, 삭제, 완료 처리
- **카테고리 시스템**: Work, Personal, Shopping, Health 등 카테고리별 분류
- **우선순위 설정**: High, Medium, Low 우선순위 지원
- **마감일 설정**: 날짜 선택을 통한 마감일 관리
- **링크 저장**: 웹 링크를 저장하고 관리하는 기능

### 🖥️ 데스크톱 특화 기능
- **시스템 트레이**: Windows에서 백그라운드 실행 지원
- **트레이 메뉴**: 우클릭으로 앱 보이기/숨기기/종료
- **데스크톱 UI**: 데스크톱 환경에 최적화된 인터페이스

### 🔥 Firebase 통합
- **실시간 동기화**: 여러 기기 간 실시간 데이터 동기화
- **사용자 인증**: Google Sign-in, Apple Sign-in 지원
- **오프라인 지원**: 네트워크가 없어도 로컬에서 작업 가능
- **데이터 정합성**: 중복 데이터 자동 정리

## 지원 플랫폼

- **Android** - 로컬 SQLite + Firebase 동기화
- **iOS** - 로컬 SQLite + Firebase 동기화  
- **Web** - Firebase 직접 사용
- **Windows** - Firebase 직접 사용 + 시스템 트레이
- **macOS** - Firebase 직접 사용 + 시스템 트레이
- **Linux** - Firebase 직접 사용

## 기술 스택

### Frontend
- **Flutter 3.x**: 크로스 플랫폼 UI 프레임워크
- **Dart**: 프로그래밍 언어

### Backend & Database
- **Firebase Firestore**: 실시간 NoSQL 데이터베이스
- **Firebase Auth**: 사용자 인증
- **SQLite**: 로컬 데이터베이스 (모바일 플랫폼)

### 상태 관리 & 아키텍처
- **Provider Pattern**: 상태 관리
- **Repository Pattern**: 데이터 계층 추상화
- **Service Layer**: 비즈니스 로직 분리

### 데스크톱 통합
- **system_tray**: 시스템 트레이 기능
- **window_manager**: 윈도우 관리
- **shared_preferences**: 로컬 설정 저장

### 개발 도구
- **build_runner**: 코드 생성
- **mockito**: 테스트 목킹
- **flutter_test**: 유닛 및 위젯 테스트

## 프로젝트 구조

```
lib/
├── data/               # 정적 데이터 (카테고리 등)
├── model/              # 데이터 모델
│   ├── todo_item.dart
│   ├── saved_link.dart
│   └── firestore_*.dart
├── screen/             # UI 화면
│   ├── todo_screen.dart
│   ├── login/
│   └── tabbar/
├── services/           # 비즈니스 로직 서비스
│   ├── firebase_sync_service.dart
│   ├── task_categorization_service.dart
│   ├── user_session_service.dart
│   └── saved_link_repository.dart
├── util/               # 유틸리티
│   └── todo_database.dart
└── main.dart           # 앱 진입점
```

## 시작하기

### 사전 요구사항
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Firebase 프로젝트 설정

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone https://github.com/krindale/todo_bloc.git
   cd todo_bloc
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **Firebase 설정**
   - Firebase Console에서 프로젝트 생성
   - `android/app/google-services.json` 추가 (Android)
   - `ios/Runner/GoogleService-Info.plist` 추가 (iOS)
   - `web/` 폴더에 Firebase 설정 추가 (Web)

4. **코드 생성**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **앱 실행**
   ```bash
   # 디버그 모드
   flutter run
   
   # 특정 플랫폼
   flutter run -d windows
   flutter run -d chrome
   ```

### 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/services/firebase_sync_service_test.dart

# 통합 테스트 실행
flutter test test/integration/
```

## 개발 가이드

### 새로운 기능 추가
1. `feature/기능명` 브랜치 생성
2. 모델 정의 (필요시)
3. 서비스 레이어 구현
4. UI 화면 구현
5. 테스트 코드 작성
6. PR 생성

### 코드 생성
```bash
# 모델 클래스 수정 후 실행
flutter packages pub run build_runner build

# 목 파일 생성
flutter packages pub run build_runner build
```

### 빌드
```bash
# Android APK
flutter build apk

# Windows 실행 파일
flutter build windows

# Web 빌드
flutter build web
```

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request