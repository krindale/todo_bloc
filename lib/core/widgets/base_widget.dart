/// **기본 위젯 구성 요소**
///
/// 앱 전체에서 일관된 위젯 구성을 위한 기본 클래스들과 믹스인을 제공합니다.
/// 공통 기능을 추상화하여 코드 중복을 줄이고 유지보수성을 높입니다.

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../utils/app_logger.dart';

/// **기본 StatefulWidget 추상 클래스**
abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
  
  /// 위젯 이름 (로깅용)
  String get widgetName => runtimeType.toString();
}

/// **기본 State 추상 클래스**
abstract class BaseState<T extends BaseStatefulWidget> extends State<T>
    with ErrorHandlingMixin implements WidgetsBindingObserver {
  
  /// 위젯이 마운트된 상태인지 여부
  @override
  bool get mounted => super.mounted;
  
  /// 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// 초기화 완료 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    AppLogger.debug(
      'Widget initialized: ${widget.widgetName}',
      tag: 'Widget',
    );
    
    // 비동기 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onDispose();
    
    AppLogger.debug(
      'Widget disposed: ${widget.widgetName}',
      tag: 'Widget',
    );
    
    super.dispose();
  }
  
  /// 비동기 초기화 로직
  Future<void> _initializeAsync() async {
    if (!mounted) return;
    
    try {
      setLoading(true);
      await onInitialize();
      _isInitialized = true;
    } catch (error, stackTrace) {
      final appError = AppError(
        type: AppErrorType.unknown,
        message: 'Failed to initialize ${widget.widgetName}',
        originalError: error,
        stackTrace: stackTrace,
      );
      
      if (mounted) {
        showError(context, appError);
      }
      
      AppLogger.error(
        'Widget initialization failed: ${widget.widgetName}',
        tag: 'Widget',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setLoading(false);
    }
  }
  
  /// 로딩 상태 설정
  void setLoading(bool loading) {
    if (_isLoading != loading && mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  /// 안전한 setState 호출
  @override
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
  
  /// 초기화 로직 (서브클래스에서 구현)
  Future<void> onInitialize() async {}
  
  /// 정리 로직 (서브클래스에서 구현)
  void onDispose() {}
  
  /// 앱 생명주기 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onAppLifecycleChanged(state);
  }
  
  /// 앱 생명주기 변경 처리 (서브클래스에서 구현)
  void onAppLifecycleChanged(AppLifecycleState state) {}
  
  /// 공통 로딩 위젯
  Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  /// 공통 에러 위젯
  Widget buildErrorWidget(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: ThemeConstants.errorColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: LayoutConstants.defaultSpacing),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ThemeConstants.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: LayoutConstants.defaultSpacing),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 공통 빈 상태 위젯
  Widget buildEmptyWidget({
    String? message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: LayoutConstants.defaultSpacing),
          Text(
            message ?? '데이터가 없습니다',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: LayoutConstants.defaultSpacing),
            action,
          ],
        ],
      ),
    );
  }
}

/// **반응형 위젯 믹스인**
mixin ResponsiveWidget on Widget {
  /// 화면 크기에 따른 반응형 값 반환
  T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= LayoutConstants.desktopBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= LayoutConstants.tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  /// 현재 플랫폼 타입
  DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= LayoutConstants.desktopBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= LayoutConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

/// **디바이스 타입**
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// **테마 인식 위젯 믹스인**
mixin ThemeAware on Widget {
  /// 현재 테마가 다크 모드인지 확인
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// 테마에 따른 색상 반환
  Color getColorByTheme(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }
  
  /// 현재 테마의 주요 색상들
  ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}

/// **애니메이션 헬퍼 믹스인**
mixin AnimationHelper<T extends StatefulWidget> on State<T>
    implements TickerProviderStateMixin {
  
  /// 페이드 애니메이션 생성
  AnimationController createFadeController({
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? AnimationConstants.fadeAnimation,
      vsync: this,
    );
  }
  
  /// 슬라이드 애니메이션 생성
  Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 0.3),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  /// 스케일 애니메이션 생성
  Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.elasticOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}

/// **리스트 위젯 헬퍼 믹스인**
mixin ListWidgetHelper {
  /// 구분선 생성
  Widget buildDivider({
    double? height,
    Color? color,
    double? thickness,
  }) {
    return Divider(
      height: height ?? 1,
      color: color ?? Colors.grey[300],
      thickness: thickness ?? 0.5,
    );
  }
  
  /// 리스트 아이템 패딩
  EdgeInsets get listItemPadding => const EdgeInsets.symmetric(
        horizontal: LayoutConstants.defaultPadding,
        vertical: LayoutConstants.smallPadding,
      );
  
  /// 빈 리스트 위젯
  Widget buildEmptyList({
    String? message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: LayoutConstants.defaultSpacing),
          Text(
            message ?? '항목이 없습니다',
            style: TextStyle(
              fontSize: TextConstants.bodyLarge,
              color: Colors.grey[600],
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: LayoutConstants.defaultSpacing),
            action,
          ],
        ],
      ),
    );
  }
}

/// **폼 위젯 헬퍼 믹스인**
mixin FormWidgetHelper {
  /// 기본 입력 필드 데코레이션
  InputDecoration getInputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool filled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: filled ? Colors.grey[50] : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LayoutConstants.defaultBorderRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.defaultPadding,
        vertical: LayoutConstants.cardPadding,
      ),
    );
  }
  
  /// 기본 버튼 스타일
  ButtonStyle getButtonStyle({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: LayoutConstants.largePadding,
        vertical: LayoutConstants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(
          LayoutConstants.defaultBorderRadius,
        ),
      ),
    );
  }
}