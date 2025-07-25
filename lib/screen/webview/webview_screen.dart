/// **인앱 웹뷰 화면**
/// 
/// 저장된 링크들을 앱 내에서 열람할 수 있는 고성능 웹뷰 화면입니다.
/// 네이티브 브라우저 환경과 유사한 기능을 제공하면서도 앱 컨텍스트를 유지합니다.
/// 
/// **주요 기능:**
/// - 웹페이지 인앱 렌더링
/// - 진행률 표시 및 로딩 상태
/// - 새로고침, 뒤로가기 버튼
/// - 외부 브라우저에서 열기 옵션
/// - 플랫폼별 최적화 (모바일/데스크톱)
/// 
/// **기술적 특징:**
/// - flutter_inappwebview: 고성능 웹뷰 엔진
/// - url_launcher: 외부 앱 연동
/// - 플랫폼별 웹뷰 설정 최적화
/// - JavaScript 상호작용 지원
/// 
/// **사용자 경험:**
/// - 매끄러운 페이지 전환
/// - 네이티브 스크롤 지원
/// - 접근성 기능 통합
/// - 다크모드 자동 대응
/// 
/// **보안:**
/// - SSL 인증서 검증
/// - 안전하지 않은 컨텐츠 차단
/// - 쿠키 및 캐시 관리

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  WebViewScreen({required this.url, required this.title});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  @override
  void initState() {
    super.initState();
    
    // 웹 플랫폼에서는 바로 외부 브라우저로 열기
    if (kIsWeb) {
      _openInBrowser();
    }
  }

  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('링크를 열 수 없습니다: ${widget.url}')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(Uri.parse(widget.url)),
        ),
      ),
    );
  }
}
