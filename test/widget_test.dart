import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cyanitalk/src/app.dart';

void main() {
  testWidgets('App builds and shows shell', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CyaniTalkApp()));

    // Verify that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
    // You might want to verify more specific widgets here once the router is fully working in test environment.
    // Note: GoRouter might require some async pumping or specific setup for tests,
    // but for now we just verify simple build.
  });
}
