import 'package:crec/app.dart';
import 'package:crec/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation exposes the six product tabs',
      (WidgetTester tester) async {
    // autoRefresh: false keeps the smoke test completely offline.
    await tester.pumpWidget(CrecApp(state: AppState(autoRefresh: false)));
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text('自选'), findsWidgets);
    expect(find.text('行情'), findsWidgets);
    expect(find.text('发现'), findsWidgets);
    expect(find.text('开户|交易'), findsWidgets);
    expect(find.text('理财'), findsWidgets);
    expect(find.text('我的'), findsWidgets);
  });
}

