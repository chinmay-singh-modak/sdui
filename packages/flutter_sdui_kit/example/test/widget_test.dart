import 'package:flutter_test/flutter_test.dart';

import '../example.dart';

void main() {
  testWidgets('ExampleApp smoke test — launches without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Home tab should be visible by default
    expect(find.text('🏠 Home'), findsOneWidget);
    expect(find.text('📝 Forms'), findsOneWidget);
    expect(find.text('🧩 Custom'), findsOneWidget);
  });

  testWidgets('Switching to Forms tab renders form screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('📝 Forms'));
    await tester.pumpAndSettle();

    // Form screen has a "Settings" heading
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Switching to Custom tab renders custom component screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('🧩 Custom'));
    await tester.pumpAndSettle();

    // Custom screen has a "Custom Components" heading
    expect(find.text('Custom Components'), findsOneWidget);
  });
}
