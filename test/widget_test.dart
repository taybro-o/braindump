// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:braindump/main.dart';

void main() {
  testWidgets('BrainDumpApp basic widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BrainDumpApp());

    // Verify that the title 'BrainDump' is rendered.
    expect(find.text('BrainDump'), findsOneWidget);

    // Verify that the loading progress indicator is present initially.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
