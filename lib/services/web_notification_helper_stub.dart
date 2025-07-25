/// 웹이 아닌 플랫폼용 스텁 파일

class WebNotificationHelper {
  static Future<String> checkNotificationPermission() async => 'denied';
  static Future<String> requestNotificationPermission() async => 'denied';
  static void showWebNotification(String title, String message) {}
  static bool isNotificationSupported() => false;
  static Future<void> testWebNotification() async {}
}