// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:caterflow_employer/main.dart';

void main() {
  testWidgets('Employer app main screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CaterFlowEmployerApp());
    await tester.pumpAndSettle();

    expect(find.text('Employer Portal'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
