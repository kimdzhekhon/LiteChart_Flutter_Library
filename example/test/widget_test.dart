// LiteChart 예제 앱 위젯 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_chart_example/main.dart';

void main() {
  testWidgets('LiteChart 데모 앱 스모크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const LiteChartDemoApp());
    expect(find.text('LiteChart Demo'), findsOneWidget);
  });
}
