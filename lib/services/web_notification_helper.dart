/// 웹 전용 알림 헬퍼 함수들
/// 
/// dart:html을 사용하여 웹 브라우저에서 푸시 알림을 처리합니다.

import 'package:flutter/foundation.dart';

// 웹 플랫폼에서만 import
import 'dart:html' as html show window;
import 'dart:js' as js show context;

// 웹이 아닌 플랫폼에서는 스텁 클래스 제공
import 'web_notification_helper_stub.dart'
    if (dart.library.js) 'web_notification_helper_web.dart';

// 조건부 export를 사용하여 플랫폼별 구현 제공
export 'web_notification_helper_stub.dart'
    if (dart.library.js) 'web_notification_helper_web.dart';