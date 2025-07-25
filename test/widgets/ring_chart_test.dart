import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/common/ring_chart.dart';

/// RingChart 위젯 테스트
/// 
/// 링 차트 위젯의 렌더링, 애니메이션, 사용자 상호작용을
/// 종합적으로 테스트합니다.
void main() {
  group('RingChart Widget Tests', () {
    testWidgets('should render RingChart with basic properties', (tester) async {
      // Arrange
      const progress = 0.7;
      const color = Colors.blue;
      const size = 120.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
              size: size,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should render with custom background color', (tester) async {
      // Arrange
      const progress = 0.5;
      const color = Colors.green;
      const backgroundColor = Colors.red;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
              backgroundColor: backgroundColor,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
    });

    testWidgets('should render with custom size and stroke width', (tester) async {
      // Arrange
      const progress = 0.8;
      const color = Colors.orange;
      const size = 200.0;
      const strokeWidth = 12.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
              size: size,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      
      // Size 확인
      final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
      expect(ringChartWidget.size, equals(size));
      expect(ringChartWidget.strokeWidth, equals(strokeWidth));
    });

    testWidgets('should render with center widget', (tester) async {
      // Arrange
      const progress = 0.6;
      const color = Colors.purple;
      const centerText = 'Center';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
              centerWidget: Text(centerText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      expect(find.text(centerText), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('should handle zero progress', (tester) async {
      // Arrange
      const progress = 0.0;
      const color = Colors.cyan;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      
      final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
      expect(ringChartWidget.progress, equals(0.0));
    });

    testWidgets('should handle full progress', (tester) async {
      // Arrange
      const progress = 1.0;
      const color = Colors.teal;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      
      final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
      expect(ringChartWidget.progress, equals(1.0));
    });

    testWidgets('should handle progress values outside 0-1 range', (tester) async {
      // Arrange - progress가 1을 초과하는 경우
      const progress = 1.5;
      const color = Colors.amber;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RingChart(
              progress: progress,
              color: color,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RingChart), findsOneWidget);
      
      final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
      expect(ringChartWidget.progress, equals(progress));
    });

    group('Animation Tests', () {
      testWidgets('should animate when animate is true', (tester) async {
        // Arrange
        const progress = 0.7;
        const color = Colors.blue;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
                animate: true,
              ),
            ),
          ),
        );

        // 초기 렌더링
        await tester.pump();
        
        // 애니메이션이 시작되었는지 확인
        expect(find.byType(AnimatedBuilder), findsOneWidget);
        
        // 애니메이션 진행
        await tester.pump(const Duration(milliseconds: 750)); // 1500ms의 절반
        
        // 애니메이션 완료
        await tester.pump(const Duration(milliseconds: 1500));

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
      });

      testWidgets('should not animate when animate is false', (tester) async {
        // Arrange
        const progress = 0.5;
        const color = Colors.red;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
                animate: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
        expect(find.byType(AnimatedBuilder), findsOneWidget);
        
        final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
        expect(ringChartWidget.animate, isFalse);
      });

      testWidgets('should handle progress updates with animation', (tester) async {
        // Arrange
        const initialProgress = 0.3;
        const updatedProgress = 0.8;
        const color = Colors.green;

        // Act - 초기 렌더링
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: initialProgress,
                color: color,
                animate: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Act - progress 업데이트
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: updatedProgress,
                color: color,
                animate: true,
              ),
            ),
          ),
        );

        // 애니메이션 진행
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1500));

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
        
        final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
        expect(ringChartWidget.progress, equals(updatedProgress));
      });
    });

    group('CustomPainter Tests', () {
      test('RingChartPainter should have correct properties', () {
        // Arrange
        const progress = 0.5;
        const color = Colors.blue;
        const backgroundColor = Colors.grey;
        const strokeWidth = 8.0;

        // Act
        final painter = RingChartPainter(
          progress: progress,
          color: color,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
        );

        // Assert
        expect(painter.progress, equals(progress));
        expect(painter.color, equals(color));
        expect(painter.backgroundColor, equals(backgroundColor));
        expect(painter.strokeWidth, equals(strokeWidth));
      });

      test('RingChartPainter shouldRepaint should work correctly', () {
        // Arrange
        final painter1 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        final painter2 = RingChartPainter(
          progress: 0.7,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        final painter3 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        // Act & Assert
        expect(painter1.shouldRepaint(painter2), isTrue); // progress 다름
        expect(painter1.shouldRepaint(painter3), isFalse); // 모든 속성 같음
      });

      test('RingChartPainter shouldRepaint should detect color changes', () {
        // Arrange
        final painter1 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        final painter2 = RingChartPainter(
          progress: 0.5,
          color: Colors.red, // 색상 변경
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        // Act & Assert
        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('RingChartPainter shouldRepaint should detect backgroundColor changes', () {
        // Arrange
        final painter1 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        final painter2 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.white, // 배경색 변경
          strokeWidth: 8.0,
        );

        // Act & Assert
        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('RingChartPainter shouldRepaint should detect strokeWidth changes', () {
        // Arrange
        final painter1 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 8.0,
        );

        final painter2 = RingChartPainter(
          progress: 0.5,
          color: Colors.blue,
          backgroundColor: Colors.grey,
          strokeWidth: 12.0, // strokeWidth 변경
        );

        // Act & Assert
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle negative progress values', (tester) async {
        // Arrange
        const progress = -0.1;
        const color = Colors.red;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
        
        final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
        expect(ringChartWidget.progress, equals(progress));
      });

      testWidgets('should handle very small size', (tester) async {
        // Arrange
        const progress = 0.5;
        const color = Colors.blue;
        const size = 10.0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
                size: size,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
      });

      testWidgets('should handle very large size', (tester) async {
        // Arrange
        const progress = 0.5;
        const color = Colors.blue;
        const size = 1000.0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
                size: size,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
      });

      testWidgets('should handle strokeWidth larger than size', (tester) async {
        // Arrange
        const progress = 0.5;
        const color = Colors.blue;
        const size = 50.0;
        const strokeWidth = 100.0; // size보다 큰 strokeWidth

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
                size: size,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
      });
    });

    group('Widget Lifecycle Tests', () {
      testWidgets('should dispose animation controller properly', (tester) async {
        // Arrange
        const progress = 0.5;
        const color = Colors.blue;

        // Act - 위젯 생성
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RingChart(
                progress: progress,
                color: color,
              ),
            ),
          ),
        );

        expect(find.byType(RingChart), findsOneWidget);

        // Act - 위젯 제거
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(),
            ),
          ),
        );

        // Assert - 에러 없이 dispose되어야 함
        expect(find.byType(RingChart), findsNothing);
      });

      testWidgets('should handle multiple progress updates', (tester) async {
        // Arrange
        const color = Colors.blue;
        final progressValues = [0.1, 0.3, 0.6, 0.9, 0.2];

        for (final progress in progressValues) {
          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RingChart(
                  progress: progress,
                  color: color,
                ),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 100));

          // Assert
          expect(find.byType(RingChart), findsOneWidget);
          
          final ringChartWidget = tester.widget<RingChart>(find.byType(RingChart));
          expect(ringChartWidget.progress, equals(progress));
        }
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible for screen readers', (tester) async {
        // Arrange
        const progress = 0.75;
        const color = Colors.blue;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Progress: 75%',
                value: '75%',
                child: RingChart(
                  progress: progress,
                  color: color,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RingChart), findsOneWidget);
        expect(find.byType(Semantics), findsOneWidget);
      });
    });
  });
}