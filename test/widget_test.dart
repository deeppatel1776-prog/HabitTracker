import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/utils/responsive_layout.dart';
import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('HabitTrackerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HabitTrackerApp()));
    expect(find.byType(HabitTrackerApp), findsOneWidget);
  });

  testWidgets('ResponsiveContent renders without overflow on narrow screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(child: SizedBox(height: 200, width: 200)),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(ResponsiveContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
