/// **테마 토글 스위치 위젯**
/// 
/// 다크모드/라이트모드를 전환할 수 있는 스위치 버튼입니다.
/// 
/// **주요 기능:**
/// - 현재 테마 상태 표시
/// - 터치로 테마 전환
/// - 부드러운 애니메이션 효과
/// - 시스템 테마 감지 및 표시
/// 
/// **디자인:**
/// - 컴팩트한 크기로 AppBar에 적합
/// - 아이콘과 텍스트로 현재 상태 명확 표시
/// - 플랫폼별 네이티브 스위치 스타일

import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

/// 테마 토글 스위치 위젯
class ThemeToggleSwitch extends StatelessWidget {
  /// 컴팩트 모드 (AppBar용)
  final bool isCompact;
  
  /// 텍스트 표시 여부
  final bool showLabel;
  
  /// 커스텀 크기
  final double? size;

  const ThemeToggleSwitch({
    super.key,
    this.isCompact = true,
    this.showLabel = false,
    this.size,
  });

  /// AppBar용 컴팩트 버전
  const ThemeToggleSwitch.compact({
    super.key,
  }) : isCompact = true,
       showLabel = false,
       size = null;

  /// 설정 화면용 전체 버전
  const ThemeToggleSwitch.full({
    super.key,
  }) : isCompact = false,
       showLabel = true,
       size = null;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        final themeService = ThemeService.instance;
        final isDarkMode = themeService.isDarkMode;
        final isSystemMode = themeService.themePreference == ThemePreference.system;

        if (isCompact) {
          return _buildCompactSwitch(context, isDarkMode, isSystemMode);
        } else {
          return _buildFullSwitch(context, isDarkMode, isSystemMode);
        }
      },
    );
  }

  /// 컴팩트 스위치 (AppBar용)
  Widget _buildCompactSwitch(BuildContext context, bool isDarkMode, bool isSystemMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _toggleTheme(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getThemeIcon(isDarkMode, isSystemMode),
                  key: ValueKey('$isDarkMode-$isSystemMode'),
                  size: size ?? 18,
                  color: isDarkMode 
                      ? Colors.amber[300] 
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  _getThemeLabel(isDarkMode, isSystemMode),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 전체 스위치 (설정 화면용)
  Widget _buildFullSwitch(BuildContext context, bool isDarkMode, bool isSystemMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getThemeIcon(isDarkMode, isSystemMode),
                  key: ValueKey('$isDarkMode-$isSystemMode'),
                  size: size ?? 24,
                  color: isDarkMode 
                      ? Colors.amber[300] 
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '테마 설정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getThemeDescription(isDarkMode, isSystemMode),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isDarkMode,
                onChanged: (_) => _toggleTheme(context),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          if (isSystemMode) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '시스템 설정 따름',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 테마 전환 처리
  void _toggleTheme(BuildContext context) {
    ThemeService.instance.toggleTheme();
    
    // 햅틱 피드백 (모바일에서)
    if (Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android) {
      // HapticFeedback.lightImpact(); // 필요시 추가
    }
  }

  /// 테마별 아이콘 반환
  IconData _getThemeIcon(bool isDarkMode, bool isSystemMode) {
    if (isSystemMode) {
      return Icons.brightness_auto;
    }
    return isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }

  /// 테마별 라벨 반환
  String _getThemeLabel(bool isDarkMode, bool isSystemMode) {
    if (isSystemMode) {
      return '자동';
    }
    return isDarkMode ? '다크' : '라이트';
  }

  /// 테마별 설명 반환
  String _getThemeDescription(bool isDarkMode, bool isSystemMode) {
    if (isSystemMode) {
      return '시스템 설정에 따라 자동으로 변경됩니다';
    }
    return isDarkMode ? '다크 모드가 활성화되어 있습니다' : '라이트 모드가 활성화되어 있습니다';
  }
}

/// 테마 설정 메뉴 아이템
class ThemeSettingsMenuItem extends StatelessWidget {
  const ThemeSettingsMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return PopupMenuButton<ThemePreference>(
          icon: Icon(
            ThemeService.instance.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: '테마 설정',
          onSelected: (ThemePreference preference) {
            ThemeService.instance.setThemePreference(preference);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.system,
              child: Row(
                children: [
                  const Icon(Icons.brightness_auto),
                  const SizedBox(width: 12),
                  const Text('시스템 설정 따름'),
                  if (ThemeService.instance.themePreference == ThemePreference.system)
                    const Spacer(),
                  if (ThemeService.instance.themePreference == ThemePreference.system)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.light,
              child: Row(
                children: [
                  const Icon(Icons.light_mode),
                  const SizedBox(width: 12),
                  const Text('라이트 모드'),
                  if (ThemeService.instance.themePreference == ThemePreference.light)
                    const Spacer(),
                  if (ThemeService.instance.themePreference == ThemePreference.light)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.dark,
              child: Row(
                children: [
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 12),
                  const Text('다크 모드'),
                  if (ThemeService.instance.themePreference == ThemePreference.dark)
                    const Spacer(),
                  if (ThemeService.instance.themePreference == ThemePreference.dark)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}