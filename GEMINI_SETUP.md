# Gemini AI 연동 설정 가이드

## 개요
Flutter Todo App에 Google Gemini AI를 연동하여 자연어 요청을 구체적인 할 일 목록으로 변환하는 기능을 제공합니다.

## 설정 방법

### 1. Gemini API 키 발급
1. [Google AI Studio](https://makersuite.google.com/app/apikey)에 접속
2. Google 계정으로 로그인
3. "Create API Key" 버튼 클릭
4. API 키 복사 (안전한 곳에 보관)

### 2. 환경 변수 설정

#### Windows (개발 환경)
```cmd
# 시스템 환경 변수 설정
setx GEMINI_API_KEY "your_actual_api_key_here"

# 또는 현재 세션만 적용
set GEMINI_API_KEY=your_actual_api_key_here
```

#### macOS/Linux
```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
export GEMINI_API_KEY="your_actual_api_key_here"

# 설정 적용
source ~/.bashrc
```

#### .env 파일 사용 (선택사항)
```bash
# 프로젝트 루트에 .env 파일 생성
cp .env.example .env

# .env 파일 편집
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. 앱 재시작
환경 변수 설정 후 Flutter 앱을 완전히 재시작해야 합니다.

```bash
flutter clean
flutter pub get
flutter run
```

## 사용 방법

### AI 할 일 생성 탭 사용
1. 앱의 "AI Generator" 탭으로 이동
2. 텍스트 입력 필드에 추상적인 목표 입력
   - 예: "건강한 생활 습관 만들기"
   - 예: "새로운 기술 배우기"
   - 예: "집 정리하기"
3. "할 일 생성" 버튼 클릭
4. AI가 생성한 구체적인 할 일 목록 확인
5. 원하는 할 일을 선택하여 메인 할 일 목록에 추가

### 지원하는 카테고리
- **건강**: 운동, 식단, 수면, 정신 건강
- **학습**: 공부, 독서, 기술 습득, 자격증
- **업무**: 직장 업무, 프로젝트, 네트워킹
- **생활**: 집안일, 취미, 인간관계, 여가
- **재정**: 저축, 투자, 가계 관리, 소비 계획
- **일반**: 기타 목표나 다양한 영역

## 폴백 메커니즘

API 키가 설정되지 않았거나 Gemini API 호출이 실패하는 경우, 자동으로 기본 템플릿 기반 생성 방식으로 전환됩니다.

### 폴백 모드에서의 동작
- 키워드 기반 카테고리 분류
- 미리 정의된 템플릿을 사용한 할 일 생성
- Gemini API보다 제한적이지만 안정적인 결과 제공

## 문제 해결

### API 키 관련 문제
```
경고: GEMINI_API_KEY 환경 변수가 설정되지 않았습니다. 폴백 모드로 실행됩니다.
```
→ 환경 변수를 다시 설정하고 앱을 재시작하세요.

### 네트워크 관련 문제
```
Gemini API 호출 실패: SocketException
```
→ 인터넷 연결을 확인하고 방화벽 설정을 점검하세요.

### API 할당량 관련 문제
```
Gemini API 호출 실패: 429 Too Many Requests
```
→ API 사용량을 확인하고 잠시 후 다시 시도하세요.

## 비용 정보

Gemini API는 사용량 기반 과금 모델을 사용합니다:
- Gemini 1.5 Flash: 매월 무료 할당량 제공
- 자세한 가격 정보: [Google AI Pricing](https://ai.google.dev/pricing)

## 보안 주의사항

1. **API 키 보안**
   - API 키를 코드에 직접 입력하지 마세요
   - 환경 변수나 보안 저장소를 사용하세요
   - API 키를 Git에 커밋하지 마세요

2. **접근 제한**
   - 필요한 경우 API 키에 IP 제한을 설정하세요
   - 정기적으로 API 키를 교체하세요

## 개발자 정보

### 코드 구조
- `lib/services/gemini_service.dart`: Gemini API 통신 서비스
- `lib/services/ai_todo_generator_service.dart`: AI 할 일 생성 메인 서비스
- `lib/screen/ai_todo_generator_screen.dart`: AI 생성 UI 화면

### 테스트 실행
```bash
# Gemini 서비스 테스트
flutter test test/services/gemini_service_test.dart

# AI 생성 서비스 테스트  
flutter test test/services/ai_todo_generator_service_test.dart
```

### 커스터마이징
프롬프트나 생성 로직을 수정하려면 `gemini_service.dart`의 `_buildPrompt()` 메서드를 편집하세요.