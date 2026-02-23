import 'package:flutter_test/flutter_test.dart';
import 'package:snap_khata/main.dart';

void main() {
  testWidgets('SnapKhata app renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapKhataApp());
    expect(find.text('SnapKhata'), findsWidgets);
  });
}
