/// 웹 전용 알림 헬퍼 함수들
/// 
/// dart:html을 사용하여 웹 브라우저에서 푸시 알림을 처리합니다.

import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class WebNotificationHelper {
  /// 웹 알림 권한 상태 확인
  static Future<String> checkNotificationPermission() async {
    if (kIsWeb) {
      try {
        // 먼저 Notification API 지원 여부 확인
        final notificationSupported = js.context.callMethod('eval', ['"Notification" in window']);
        if (notificationSupported != true) {
          debugPrint('❌ 이 브라우저는 Notification API를 지원하지 않습니다');
          return 'denied';
        }
        
        final permission = js.context.callMethod('eval', ['Notification.permission']);
        final permissionStr = permission.toString();
        debugPrint('🔔 현재 알림 권한 상태: $permissionStr');
        return permissionStr;
      } catch (e) {
        debugPrint('❌ 알림 권한 확인 실패: $e');
        return 'denied';
      }
    }
    return 'denied';
  }

  /// 웹 알림 권한 요청
  static Future<String> requestNotificationPermission() async {
    if (kIsWeb) {
      try {
        debugPrint('🔔 알림 권한을 요청합니다...');
        
        // Promise를 처리하기 위해 JavaScript 함수 사용
        final jsCode = '''
          (async function() {
            try {
              const permission = await Notification.requestPermission();
              console.log('알림 권한 요청 결과:', permission);
              return permission;
            } catch (error) {
              console.error('알림 권한 요청 실패:', error);
              return 'denied';
            }
          })()
        ''';
        
        final result = await js.context.callMethod('eval', [jsCode]);
        final resultStr = result.toString();
        debugPrint('🔔 알림 권한 요청 결과: $resultStr');
        return resultStr;
      } catch (e) {
        debugPrint('❌ 알림 권한 요청 실패: $e');
        return 'denied';
      }
    }
    return 'denied';
  }

  /// 웹 알림 표시
  static void showWebNotification(String title, String message) {
    if (kIsWeb) {
      try {
        debugPrint('🔔 웹 알림 표시 시도: $title - $message');
        
        final jsCode = '''
          (function() {
            console.log("=== 웹 알림 디버깅 시작 ===");
            console.log("Notification in window:", "Notification" in window);
            console.log("Notification.permission:", Notification.permission);
            
            if ("Notification" in window) {
              if (Notification.permission === "granted") {
                try {
                  const notification = new Notification("$title", {
                    body: "$message",
                    icon: "/favicon.ico",
                    badge: "/favicon.ico",
                    tag: "todo-notification-" + Date.now(),
                    renotify: true,
                    requireInteraction: false,
                    silent: false,
                    timestamp: Date.now()
                  });
                  
                  notification.onclick = function() {
                    console.log("알림이 클릭되었습니다");
                    window.focus();
                    notification.close();
                  };
                  
                  notification.onshow = function() {
                    console.log("알림이 표시되었습니다");
                  };
                  
                  notification.onerror = function(error) {
                    console.error("알림 오류:", error);
                  };
                  
                  // 5초 후 자동으로 닫기
                  setTimeout(() => {
                    notification.close();
                    console.log("알림이 자동으로 닫혔습니다");
                  }, 5000);
                  
                  console.log("✅ 웹 알림 생성 성공:", "$title - $message");
                  return "success";
                } catch (error) {
                  console.error("❌ 알림 생성 실패:", error);
                  return "error: " + error.message;
                }
              } else {
                console.log("❌ 알림 권한 없음:", Notification.permission);
                return "no_permission";
              }
            } else {
              console.log("❌ Notification API 지원 안됨");
              return "not_supported";
            }
          })()
        ''';
        
        final result = js.context.callMethod('eval', [jsCode]);
        final resultStr = result.toString();
        
        debugPrint('🔔 웹 알림 결과: $resultStr');
        
        if (resultStr == "success") {
          debugPrint('✅ 웹 알림 성공적으로 표시됨: $title - $message');
        } else {
          debugPrint('❌ 웹 알림 표시 실패: $resultStr');
        }
      } catch (e) {
        debugPrint('❌ 웹 알림 JavaScript 실행 실패: $e');
      }
    }
  }

  /// 알림 지원 여부 확인
  static bool isNotificationSupported() {
    if (kIsWeb) {
      try {
        final supported = js.context.callMethod('eval', ['"Notification" in window']);
        return supported == true;
      } catch (e) {
        debugPrint('알림 지원 여부 확인 실패: $e');
        return false;
      }
    }
    return false;
  }

  /// 웹 알림 테스트
  static Future<void> testWebNotification() async {
    if (!isNotificationSupported()) {
      debugPrint('❌ 이 브라우저는 웹 알림을 지원하지 않습니다');
      return;
    }

    final permission = await checkNotificationPermission();
    debugPrint('현재 알림 권한: $permission');

    if (permission == 'granted') {
      showWebNotification('테스트 알림', '웹 푸시 알림이 정상적으로 작동합니다!');
    } else if (permission == 'default') {
      debugPrint('알림 권한을 요청합니다...');
      final result = await requestNotificationPermission();
      debugPrint('권한 요청 결과: $result');
      
      if (result == 'granted') {
        showWebNotification('테스트 알림', '웹 푸시 알림이 정상적으로 작동합니다!');
      } else {
        debugPrint('❌ 알림 권한이 거부되었습니다');
      }
    } else {
      debugPrint('❌ 알림 권한이 차단되어 있습니다');
    }
  }
}